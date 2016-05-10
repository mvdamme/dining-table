module DiningTable
  
  module Presenters

    class ExcelPresenter < SpreadsheetPresenter
      
      def initialize( worksheet, *args )
        super( *args )
        self.worksheet = worksheet
      end
      
      def identifier
        :xlsx
      end
      
      private
      
        attr_accessor :worksheet
        
        def add_row(array)
          worksheet.add_row( array )
        end

    end

  end

end