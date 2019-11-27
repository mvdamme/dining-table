module DiningTable
  
  module Presenters

    class HTMLPresenter < Presenter

      attr_accessor :tags_configuration, :table_tags_configuration, :base_tags_configuration, :table_config_block, :row_config_block

      attr_writer :output
      private :output, :output=

      def initialize( options = {} )
        super
        self.base_tags_configuration = HTMLPresenterConfiguration::TagsConfiguration.from_hash( default_options )
        base_tags_configuration.merge_hash( options )
        self.output = ''.html_safe
      end
      
      def identifier
        :html
      end
      
      def start_table
        set_up_configuration
        if options[:wrap]
          add_tag(:start, wrap_tag, wrap_options )
        end
        add_tag(:start, :table, table_options )
      end
      
      def end_table
        add_tag(:end, :table)
        if options[:wrap]
          add_tag(:end, wrap_tag )
        end
      end
      
      def start_body
        add_tag(:start, :tbody, tag_options(:tbody))
      end
      
      def end_body
        add_tag(:end, :tbody)
      end
      
      def render_row( object )
        set_up_row_configuration( table.index, object )
        add_tag(:start, :tr, row_options)
        columns.each do |column|
          value = column.value( object )
          configuration = cell_configuration( tags_configuration, column, table.index, object )
          render_cell( value, configuration )
        end
        add_tag(:end,   :tr)
      end

      def render_header
        set_up_row_configuration( :header, nil )
        add_tag(:start, :thead, tag_options(:thead))
        add_tag(:start, :tr, row_options)
        columns.each do |column|
          value = column.header
          configuration = cell_configuration( tags_configuration, column, :header, nil )
          render_header_cell( value, configuration )
        end
        add_tag(:end,   :tr)
        add_tag(:end,   :thead)
      end
      
      def render_footer
        set_up_row_configuration( :footer, nil )
        footers = columns.each.map(&:footer)
        if footers.map { |s| blank?(s) }.uniq != [ true ]
          add_tag(:start, :tfoot, tag_options(:tfoot))
          add_tag(:start, :tr, row_options)
          columns.each_with_index do |column, index|
            value = footers[index]
            configuration = cell_configuration( tags_configuration, column, :footer, nil )
            render_footer_cell( value, configuration )
          end
          add_tag(:end,   :tr)
          add_tag(:end,   :tfoot)
        end
      end

      def output
        @output
      end

      def table_config(&block)
        self.table_config_block = block
      end

      def row_config(&block)
        self.row_config_block = block
      end

      private
      
        def output_
          @output
        end
        
        def add_tag(type, tag, options = {})
          string = send("#{ type.to_s }_tag", tag, options)
          output_ << string
        end
      
        def start_tag(tag, options = {})
          "<#{ tag.to_s }#{ options_string(options) }>".html_safe
        end
      
        def end_tag(tag, options = {})
          "</#{ tag.to_s }>".html_safe
        end

        def render_cell( string, configuration )
          render_general_cell( string, configuration, :td)
        end

        def render_header_cell( string, configuration )
          render_general_cell( string, configuration, :th)
        end

        def render_footer_cell( string, configuration )
          render_cell( string, configuration )
        end

        def render_general_cell( string, configuration, cell_tag )
          add_tag(:start, cell_tag, tag_options(cell_tag, configuration) )
          output_ << string.to_s
          add_tag(:end,   cell_tag)
        end

        def options_string(options)
          return '' if options.nil?
          options.each_key.inject('') do |result, key|
            result += " #{key.to_s}=\"#{ options[key] }\"" if !options_to_skip.include?( key )
            result
          end
        end
        
        # don't output these keys as html options in options_string
        def options_to_skip
          [ :wrap ]
        end

        def wrap_tag
          options[:wrap][:tag]
        end

        def wrap_options
          options_ = options[:wrap].dup
          options_.delete(:tag)
          options_
        end

        def table_options
          options_ = tag_options(:table)
          return options_ unless options_.empty?
          if options[:class]
            warn "[DEPRECATION] dining-table: option \"class\" is deprecated, please use \"tags: { table: { class: 'my_class' } }\" instead."
            { :class => options[:class] }
          else
            { }
          end
        end

        def row_options
          tag_options(:tr)
        end

        def column_options_cache( column )
          @column_options_cache ||= { }
          @column_options_cache[ column ] ||= begin
            column_options = column.options_for( identifier )
            if column_options.is_a?(Hash)
              if column_options[:th_options] || column_options[:td_options]
                warn "[DEPRECATION] dining-table: options \"th_options\" and \"td_options\" are deprecated, please use \"th\" and \"td\" instead. Example: \"{ td: { class: 'my_class' } }\"."
                column_options[:th] = column_options.delete(:th_options)
                column_options[:td] = column_options.delete(:td_options)
              end
              column_options[:tags] ? column_options : { :tags => column_options }
            elsif column_options.respond_to?(:call)
              column_options
            end
          end
        end

        def cell_configuration( start_configuration, column, index, object )
          column_options = column_options_cache( column )
          return start_configuration if !column_options
          new_configuration = start_configuration.dup
          if column_options.is_a?(Hash)
            new_configuration.merge_hash( column_options )
          else # callable
            column_options.call( new_configuration, index, object )
            new_configuration
          end
        end

        def tag_options( tag, configuration = nil )
          configuration ||= tags_configuration
          configuration.send( tag ).to_h
        end

        def set_up_configuration
          self.table_tags_configuration = base_tags_configuration.dup
          table_config_block.call( table_tags_configuration ) if table_config_block
          self.tags_configuration = table_tags_configuration.dup
        end

        def set_up_row_configuration( index, object )
          self.tags_configuration = table_tags_configuration.dup
          row_config_block.call( tags_configuration, index, object ) if row_config_block
        end

    end

  end

end