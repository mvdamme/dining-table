module DiningTable
  
  module Columns

    class ActionsColumn < Column
      
      def value(object)
        if block
          @incremental_value = ''.html_safe
          @current_object = object
          self.instance_eval(&block)
          @incremental_value
        end
      end
      
      private
      
        def action(&block)
          action_value = table.instance_exec(@current_object, &block)
          @incremental_value += action_value.to_s if action_value && action_value.respond_to?(:to_s)
        end

        # offer methods normally available on Table that could be used by the action-column block
        [ :h, :helpers, :collection, :index, :presenter ].each do |method|
          self.class_eval <<-eos, __FILE__, __LINE__+1
            def #{method}(*args)
              table.#{method}
            end
          eos
        end

    end

  end

end