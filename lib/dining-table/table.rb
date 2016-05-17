module DiningTable

  class Table
    
    attr_accessor :collection, :presenter, :options, :index, :columns, :action_columns, :view_context
    
    def initialize( collection, view_context, options = {} )
      self.collection = collection
      self.view_context = view_context
      self.index     = 0
      self.columns   = [ ]
      self.options   = options
      initialize_presenter( options )
    end
    
    def render
      presenter.start_table
      presenter.render_header unless no_header
      collection.each_with_index do |object, index_|
        self.index = index_
        presenter.render_row( object )
      end
      presenter.render_footer
      presenter.end_table
      presenter.output
    end
    
    def helpers
      view_context
    end
    alias_method :h, :helpers
    
    private
    
      attr_accessor :no_header
    
      # auxiliary function
      def column(name, options = {}, &block)
        klass = options[:class]
        klass ||= Columns::Column
        self.columns << klass.new(self, name, options, &block)
      end
      
      def actions(options = {}, &block)
        column(:actions__, { :class => Columns::ActionsColumn }.merge( options ), &block )
      end
      
      def initialize_presenter( options )
        self.presenter = options[ :presenter ]
        self.presenter ||= default_presenter.new(options)
        self.presenter.connect_to( self )
      end
      
      def default_presenter
        Presenters::HTMLPresenter
      end
      
      def skip_header
        self.no_header = true
      end
      
  end

end