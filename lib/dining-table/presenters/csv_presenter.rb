require 'csv'

module DiningTable
  
  module Presenters

    class CSVPresenter < SpreadsheetPresenter
      
      def initialize( *args )
        super
        self.output = ''
      end
      
      def identifier
        :csv
      end
      
      def output
        stringio.string
      end
      
      private
      
        attr_writer :output
        attr_accessor :stringio
        
        def csv
          @csv ||= begin
            self.stringio = StringIO.new
            csv_options = options[:csv] || { }
            CSV.new(stringio, csv_options)
          end
        end
        
        def add_row(array)
          csv.add_row( array )
        end

    end

  end

end