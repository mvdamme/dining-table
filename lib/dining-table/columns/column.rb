module DiningTable
  
  module Columns

    class Column
      
      attr_accessor :name, :table, :options, :block
      
      def initialize( table, name, options = {}, &block)
        self.table = table
        self.name = name
        self.options = options
        self.block = block
      end
      
      def value(object)
        if block
          block.call(object)
        else
          object.send(name).try(:to_s) if object.respond_to?(name)
        end
      end
      
      def header
        @header ||= begin
          label = determine_label(:header)
          return label if label
          object_class = table.collection.first.try(:class)
          object_class.human_attribute_name( name) if object_class
        end
      end

      def footer
        @footer ||= determine_label(:footer)
      end
      
      def options_for(identifier)
        options[ identifier ] || { }
      end
    
      private
      
        def determine_label( name )
          if options[ name ]
            label_ = options[ name ]
            label_ = label_.call if label_.respond_to?(:call)
            return label_.try(:to_s) 
          end
        end
      
    end

  end

end