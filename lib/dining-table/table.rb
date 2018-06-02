module DiningTable

  class Table
    
    attr_accessor :collection, :presenter, :options, :index, :columns, :action_columns, :view_context

    attr_accessor :no_header, :no_footer
    private :no_header, :no_footer, :no_header=, :no_footer=

    def initialize( collection, view_context, options = {} )
      self.collection = collection
      self.view_context = view_context
      self.index     = 0
      self.columns   = [ ]
      self.options   = options
      initialize_presenter( options )
      define
    end
    
    def define
      raise NotImplementedError
    end
    
    def render
      presenter.start_table
      presenter.render_header unless no_header
      presenter.start_body
      collection.each_with_index do |object, index_|
        self.index = index_
        presenter.render_row( object )
      end
      presenter.end_body
      presenter.render_footer unless no_footer
      presenter.end_table
      presenter.output
    end
    
    def helpers
      view_context
    end
    alias_method :h, :helpers

    def skip_header
      self.no_header = true
    end

    def skip_footer
      self.no_footer = true
    end

    private
    
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
        self.presenter ||= default_presenter.new
        self.presenter.connect_to( self )
      end
      
      def default_presenter
        Presenters::HTMLPresenter
      end
      
  end

end