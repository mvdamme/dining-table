# configuration, see http://robots.thoughtbot.com/mygem-configure-block.
module DiningTable

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class PresenterConfiguration
    attr_accessor :default_options

    def initialize
      @default_options = { }
    end
  end

  class Configuration
    attr_accessor :html_presenter
    attr_accessor :csv_presenter
    attr_accessor :excel_presenter

    def initialize
      @html_presenter  = PresenterConfiguration.new
      @csv_presenter   = PresenterConfiguration.new
      @excel_presenter = PresenterConfiguration.new
    end
  end

end
