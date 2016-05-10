module DiningTable
  
  module Columns

    class ActionsColumn < Column
      
      def value(object)
        if block
          @incremental_value = ''
          @current_object = object
          self.instance_eval(&block)
          @incremental_value
        end
      end
      
      private
      
        def action(&block)
          action_value = yield(@current_object)
          @incremental_value += action_value.try(:to_s) if action_value
        end

        # offer methods normally available on Table that could be used by the action blocks
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