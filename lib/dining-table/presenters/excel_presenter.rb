module DiningTable
  
  module Presenters

    class ExcelPresenter < SpreadsheetPresenter

      attr_accessor :worksheet
      private :worksheet, :worksheet=

      def initialize( worksheet, *args )
        super( *args )
        self.worksheet = worksheet
      end
      
      def identifier
        :xlsx
      end
      
      private
      
        def add_row(array)
          worksheet.add_row( array )
        end

    end

  end

end