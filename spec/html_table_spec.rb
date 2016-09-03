require 'spec_helper'
require 'collection'
require 'rexml/document'
Dir["#{File.dirname(__FILE__)}/tables/**/*.rb"].each {|file| require file }


describe 'HTMLTableSpec' do
  before do
    @cars = Car.collection
    @view_context = ViewContext.new
  end
  
  it "correctly renders a basic table's body" do
    html = CarTable.new(@cars, nil).render
    doc = document( html )
    @cars.each_with_index do |car, index|
      [ :brand, :number_of_doors, :stock ].each_with_index do |column, col_index|
        xpath = "/table/tbody/tr[#{ index + 1 }]/td[#{ col_index + 1 }]"
        check_not_empty(doc.elements, xpath)
        doc.elements.each(xpath) do |element|
          element.text.must_equal car.send( column ).to_s
        end
      end
    end
  end

  it "correctly renders a table's header when no explicit headers are defined" do
    @cars = CarWithHumanAttributeName.collection
    html = CarTable.new(@cars, nil).render
    doc = document( html )
    [ 'Brand', 'Number of doors', 'Stock' ].each_with_index do |header, col_index|
      xpath = "/table/thead/tr[1]/th[#{ col_index + 1 }]"
      check_not_empty(doc.elements, xpath)
      doc.elements.each(xpath) do |element|
        element.text.must_equal header
      end
    end
  end
  
  it "correctly renders a table's header when explicit headers are defined" do
    @cars = CarWithHumanAttributeName.collection
    html = CarTableWithHeader.new(@cars, @view_context).render
    doc = document( html )
    [ 'The brand', 'The number of doors' ].each_with_index do |header, col_index|
      xpath = "/table/thead/tr[1]/th[#{ col_index + 1 }]"
      check_not_empty(doc.elements, xpath)
      doc.elements.each(xpath) do |element|
        element.text.must_equal header
      end
    end
    # last header has link
    doc.elements.each("/table/thead/tr[1]/th[3]/a") do |element|
      element.text.must_equal 'Stock'
      element.attributes.get_attribute('href').value.must_equal "http://www.google.com"
    end
  end

  it "correctly renders a table's footer when footers are defined" do
    @cars = CarWithHumanAttributeName.collection
    html = CarTableWithFooter.new(@cars, @view_context).render
    doc = document( html )
    [ nil, 'Total' ].each_with_index do |footer, col_index|
      xpath = "/table/tfoot/tr[1]/td[#{ col_index + 1 }]"
      check_not_empty(doc.elements, xpath)
      doc.elements.each(xpath) do |element|
        element.text.must_equal footer
      end
    end
    # last footer has link
    doc.elements.each("/table/tfoot/tr[1]/th[3]/a") do |element|
      element.text.must_equal "Total: #{ 150 }"
      element.attributes.get_attribute('href').value.must_equal "#"
    end
  end

  it "correctly renders a table with column options and column blocks" do
    html = CarTableWithOptions.new(@cars, nil).render
    doc = document( html )
    @cars.each_with_index do |car, index|
      [ :brand, :stock ].each_with_index do |column, col_index|
        xpath = "/table/tbody/tr[#{ index + 1 }]/td[#{ col_index + 1 }]"
        check_not_empty(doc.elements, xpath)
        doc.elements.each(xpath) do |element|
          element.text.must_equal car.send( column ).to_s.upcase
          class_ = col_index == 0 ? 'center' : 'left'
          element.attributes.get_attribute('class').value.must_equal class_
        end
      end
    end
    # also check header
    [ 1, 2 ].each do |index|
      doc.elements.each("/table/thead/tr[1]/th[#{ index }]") do |element|
        class_ = index == 1 ? 'center' : 'left'
        element.attributes.get_attribute('class').value.must_equal class_
      end
    end
  end

  it "correctly renders a table with actions" do
    html = CarTableWithActions.new(@cars, @view_context).render
    doc = document( html )
    @cars.each_with_index do |car, index|
      xpath = "/table/tbody/tr[#{ index + 1 }]/td[3]/a"
      check_not_empty(doc.elements, xpath)
      doc.elements.each_with_index(xpath) do |element, idx|
        text = (idx == 0 ? 'Show' : 'Edit')
        link = (idx == 0 ? '#show' : '#edit')
        element.text.must_equal text
        element.attributes.get_attribute('href').value.must_equal link
      end
      # check options
      xpath = "/table/tbody/tr[#{ index + 1 }]/td[3]"
      doc.elements.each(xpath) do |element|
        element.attributes.get_attribute('class').value.must_equal 'left'
      end
    end
  end
  
  it "respects presenter options" do
    html = CarTable.new(@cars, nil,
                        :presenter => DiningTable::Presenters::HTMLPresenter.new( :class => 'table table-bordered' ) ).render
    doc = document( html )
    doc.elements.first.attributes.get_attribute('class').value.must_equal 'table table-bordered'
  end

  it "correctly wraps the table" do
    html = CarTable.new(@cars, nil,
                        :presenter => DiningTable::Presenters::HTMLPresenter.new( :wrap => { :tag => :div, :class => 'table-responsive' } ) ).render
    doc = REXML::Document.new( html )
    doc.elements.first.name.must_equal 'div'
    doc.elements.first.attributes.get_attribute('class').value.must_equal 'table-responsive'
  end

  it "respects global html options" do
    DiningTable.configure do |config|
      config.html_presenter.default_options = { :class => 'table-hover',
                                                :wrap => { :tag => :div, :class => 'table-responsive' } }
    end
    html = CarTable.new(@cars, nil).render
    doc = REXML::Document.new( html )
    doc.elements.first.name.must_equal 'div'
    doc.elements.first.attributes.get_attribute('class').value.must_equal 'table-responsive'
    table = doc.elements.first.elements.first
    table.attributes.get_attribute('class').value.must_equal 'table-hover'
    # reset configuration for other specs
    DiningTable.configure do |config|
      config.html_presenter.default_options = {  }
    end
  end

  def document( html )
    doc = REXML::Document.new( html )
    check_table_structure( doc )
    doc
  end
  
  def check_table_structure( document )
    document.elements.size.must_equal 1
    table = document.elements.first
    table.name.must_equal 'table'
    (table.elements.size >= 2).must_equal true
    header = table.elements.first
    header.name.must_equal 'thead'
    body = table.elements[2]  # 2 = second element (not third) in REXML
    body.name.must_equal 'tbody'
    if table.elements.size == 3
      footer = table.elements[3]
      footer.name.must_equal 'tfoot'
    end
  end
  
  def not_empty?(node, xpath)
    node.each(xpath) do 
      return true
    end
    false
  end

  def check_not_empty(node, xpath)
    not_empty?(node, xpath).must_equal true
  end

  class ViewContext
    def link_to(text, url)
      "<a href=\"#{ url }\">#{ text }</a>"
    end
  end
  
end