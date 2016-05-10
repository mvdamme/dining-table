module DiningTable
  
  module Presenters

    class Presenter
      
      attr_accessor :table, :options, :view_context
      
      def initialize( options = {} )
        self.options = options
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
      
      [ :start_table, :end_table, :render_header, :start_body, :end_body, :row, :render_footer, :output ].each do |method|
        self.class_eval <<-eos, __FILE__, __LINE__+1
          def #{method}(*args)
          end
        eos
      end
      
      private
      
        def columns
          table.columns
        end
        
    end

  end

end