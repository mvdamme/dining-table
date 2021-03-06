module DiningTable
  
  module Presenters

    class Presenter
      
      attr_accessor :table, :options, :view_context
      
      def initialize( options = {} )
        self.options = default_options.merge( options )
      end
      
      def connect_to( table )
        self.table = table
      end
      
      def identifier
        raise NotImplementedError
      end
      
      def type?( identifier_ )
        identifier == identifier_
      end
      
      [ :start_table, :end_table, :render_header, :start_body, :end_body, :render_row, :render_footer, :output ].each do |method|
        self.class_eval <<-eos, __FILE__, __LINE__+1
          def #{method}(*args)
          end
        eos
      end
      
      private
      
        def columns
          table.columns
        end
        
        def default_options
          presenter = "#{ identifier }_presenter"
          if DiningTable.configuration.respond_to?( presenter )
            DiningTable.configuration.send( presenter ).default_options
          else
            { }
          end
        end

        # implementation adapted from ActiveSupport
        def blank?( string )
          string.respond_to?(:empty?) ? !!string.empty? : !string
        end

    end

  end

end