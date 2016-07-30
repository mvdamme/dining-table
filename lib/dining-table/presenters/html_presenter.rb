module DiningTable
  
  module Presenters

    class HTMLPresenter < Presenter
      
      def initialize( *args )
        super
        self.output  = ''
      end
      
      def identifier
        :html
      end
      
      def start_table
        if options[:wrap]
          add_tag(:start, wrap_tag, wrap_options )
        end
        add_tag(:start, :table, options )
      end
      
      def end_table
        add_tag(:end, :table)
        if options[:wrap]
          add_tag(:end, wrap_tag )
        end
      end
      
      def start_body
        add_tag(:start, :tbody)
      end
      
      def end_body
        add_tag(:end, :tbody)
      end
      
      def render_row( object )
        add_tag(:start, :tr)
        columns.each do |column|
          value = column.value( object )
          render_cell( value, column.options_for( identifier ) )
        end
        add_tag(:end,   :tr)
      end

      def render_header
        add_tag(:start, :thead)
        add_tag(:start, :tr)
        columns.each do |column|
          value = column.header
          render_header_cell( value, column.options_for( identifier )  )
        end
        add_tag(:end,   :tr)
        add_tag(:end,   :thead)
      end
      
      def render_footer
        footers = columns.each.map(&:footer)
        if footers.map(&:blank?).uniq != [ true ]
          add_tag(:start, :tfoot)
          add_tag(:start, :tr)
          columns.each_with_index do |column, index|
            value = footers[index]
            render_footer_cell( value, column.options_for( identifier )  )
          end
          add_tag(:end,   :tr)
          add_tag(:end,   :tfoot)
        end
      end

      def output
        @output.html_safe
      end
      
      private
      
        attr_writer :output
        
        def output_
          @output
        end
        
        def add_tag(type, tag, options = {})
          string = send("#{ type.to_s }_tag", tag, options)
          output_ << string
        end
      
        def start_tag(tag, options = {})
          "<#{ tag.to_s } #{ options_string(options) }>"
        end
      
        def end_tag(tag, options = {})
          "</#{ tag.to_s }>"
        end
        
        def render_cell( string, options )
          render_general_cell( string, options, :td, :td_options )
        end

        def render_header_cell( string, options )
          render_general_cell( string, options, :th, :th_options )
        end
        
        def render_footer_cell( string, options )
          render_general_cell( string, options, :td, :footer_options )
        end
        
        def render_general_cell( string, options, cell_tag, options_identifier )
          add_tag(:start, cell_tag, options[ options_identifier ] )
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
        
    end

  end

end