module DiningTable
  
  module Presenters

    class SpreadsheetPresenter < Presenter
      
      def render_row( object )
        values = columns.map do |column|
          value = column.value( object )
          value = clean( value ) if !!options[:clean]
          value
        end
        add_row( values )
      end

      def render_header
        add_row( header_strings )
      end
      
      def render_footer
        footers = footer_strings
        if footers.map { |s| blank?(s) }.uniq != [ true ]
          add_row( footers )
        end
      end
      
      private
      
        def header_strings
          columns.map(&:header)
        end
        
        def footer_strings
          columns.map(&:footer)
        end

        def add_row( row )
          raise NotImplementedError
        end

        def clean(string)
          replacements = [['&mdash;', '--'], ['&ndash;', '-'], ['&nbsp;', ' '] ]
          base = view_context.strip_tags(string)
          replacements.each do |pattern, replacement|
            base.gsub!(pattern, replacement)
          end
          base
        end
        
    end

  end

end