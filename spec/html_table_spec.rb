require 'spec_helper'
require 'collection'
require 'date_column'
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

  it "correctly renders a table's header when the table body is empty and a class is provided" do
    html = CarTable.new([], nil, :class => CarWithHumanAttributeName).render
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

  it "correctly renders a table's header when explicit headers are defined and the table body is empty" do
    html = CarTableWithHeader.new([], @view_context).render
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
        element.text.must_equal footer if footer
        element.text.must_be_nil if !footer  # avoid minitest deprecation warning
      end
    end
    # last footer has link
    doc.elements.each("/table/tfoot/tr[1]/th[3]/a") do |element|
      element.text.must_equal "Total: #{ 150 }"
      element.attributes.get_attribute('href').value.must_equal "#"
    end
  end

  it "allows skipping header and footer" do
    @cars = CarWithHumanAttributeName.collection
    html = CarTableWithoutHeader.new(@cars, @view_context).render
    doc = REXML::Document.new( html )
    table = doc.elements.first
    table.elements.size.must_equal 1  # only body
    table.elements.first.name.must_equal 'tbody'
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

  it "still supports deprecated syntax for html column options" do
    html = CarTableWithOptionsOldSyntax.new(@cars, nil).render
    doc = document( html )
    @cars.each_with_index do |car, index|
      [ :brand, :stock ].each_with_index do |column, col_index|
        xpath = "/table/tbody/tr[#{ index + 1 }]/td[#{ col_index + 1 }]"
        check_not_empty(doc.elements, xpath)
        doc.elements.each(xpath) do |element|
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
  
  it "respects custom columns when specified" do
    # first without custom column
    html = CarTableWithOptions.new(@cars, nil, :with_normal_launch_date => true).render
    doc = document( html )
    @cars.each_with_index do |car, index|
      xpath = "/table/tbody/tr[#{ index + 1 }]/td[3]"
      check_not_empty(doc.elements, xpath)
      doc.elements.each(xpath) do |element|
        element.text.must_equal car.launch_date.to_s
      end
    end
    # now with custom date column
    html = CarTableWithOptions.new(@cars, nil, :with_date_column_launch_date => true).render
    doc = document( html )
    @cars.each_with_index do |car, index|
      xpath = "/table/tbody/tr[#{ index + 1 }]/td[3]"
      check_not_empty(doc.elements, xpath)
      doc.elements.each(xpath) do |element|
        element.text.must_equal DateColumn.localize( car.launch_date )
      end
    end
  end

  it "respects presenter options" do
    html = CarTableWithFooter.new(@cars, @view_context,
                            :presenter => DiningTable::Presenters::HTMLPresenter.new(
                            :tags => { :table => { :class => 'table table-bordered', :id => 'my_table_id', :'data-custom' => 'custom1!' },
                                       :thead => { :class => 'mythead', :id => 'my_thead_id', :'data-custom' => 'custom2!' },
                                       :tbody => { :class => 'mytbody', :id => 'my_tbody_id', :'data-custom' => 'custom3!' },
                                       :tfoot => { :class => 'mytfoot', :id => 'my_tfoot_id', :'data-custom' => 'custom4!' },
                                       :tr => { :class => 'mytr', :'data-custom' => 'custom5!' },
                                       :th => { :class => 'myth', :'data-custom' => 'custom6!' },
                                       :td => { :class => 'mytd', :'data-custom' => 'custom7!' }
                                       } ) ).render
    doc = document( html )
    table = doc.elements.first
    check_attributes( table, ['class', 'id', 'data-custom'], ['table table-bordered', 'my_table_id', 'custom1!'])
    header = table.elements[1] # 1 = first element (not second) in REXML
    check_attributes( header, ['class', 'id', 'data-custom'], ['mythead', 'my_thead_id', 'custom2!'])
    body = table.elements[2]   # 2 = second element (not third) in REXML
    check_attributes( body, ['class', 'id', 'data-custom'], ['mytbody', 'my_tbody_id', 'custom3!'])
    footer = table.elements[3] # 3 = third element (not fourth) in REXML
    check_attributes( footer, ['class', 'id', 'data-custom'], ['mytfoot', 'my_tfoot_id', 'custom4!'])
    row = header.elements.first
    check_attributes( row, ['class', 'data-custom'], ['mytr', 'custom5!'])
    row.elements.each do |header_cell|
      check_attributes( header_cell, ['class', 'data-custom'], ['myth', 'custom6!'])
    end
    body.elements.each do |row_|
      check_attributes( row_, ['class', 'data-custom'], ['mytr', 'custom5!'])
    end
    row = footer.elements.first
    check_attributes( row, ['class', 'data-custom'], ['mytr', 'custom5!'])
  end

  it "still supports old (deprecated) way of specifying the table class" do
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
      config.html_presenter.default_options = { :tags => { :table => { :class => 'table-hover' }, :tr => { :class => 'rowrow' } },
                                                :wrap => { :tag => :div, :class => 'table-responsive' } }
    end
    html = CarTable.new(@cars, nil).render
    doc = REXML::Document.new( html )
    doc.elements.first.name.must_equal 'div'
    doc.elements.first.attributes.get_attribute('class').value.must_equal 'table-responsive'
    table = doc.elements.first.elements.first
    table.attributes.get_attribute('class').value.must_equal 'table-hover'
    body = table.elements[2]
    body.elements.each do |row|
      row.attributes.get_attribute('class').value.must_equal 'rowrow'
    end
    # reset configuration for other specs
    DiningTable.configure do |config|
      config.html_presenter.default_options = {  }
    end
  end

  it "respects in-table presenter config blocks" do
    html = CarTableWithConfigBlocks.new(@cars, @view_context).render
    doc = REXML::Document.new( html )
    table = doc.elements.first
    table.attributes.get_attribute('class').value.must_equal 'my-table-class'
    header = table.elements.first
    header.attributes.get_attribute('class').value.must_equal 'my-thead-class'
    row = header.elements.first
    row.attributes.get_attribute('class').value.must_equal 'header-tr'
    row.elements.each do |cell|
      cell.attributes.get_attribute('class').value.must_equal 'header-th'
    end
    body = table.elements[2]
    body.elements.each_with_index do |row_, index|
      row_.attributes.get_attribute('class').value.must_match( index.odd? ? /odd/ : /even/ )
      row_.attributes.get_attribute('class').value.must_match( /lowstock/ ) if @cars[index].stock < 10
      row_.elements.each_with_index do |td, td_index|
        if td_index == 0
          td.attributes.get_attribute('class').value.must_equal 'left'
        elsif td_index == 1
          td.attributes.get_attribute('class').value.must_match( /center/ )
          td.attributes.get_attribute('class').value.must_match( /five_doors/ ) if @cars[index].number_of_doors == 5
        else
          td.attributes.get_attribute('class').must_be_nil if td_index != 1
        end
      end
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

  def check_attributes( element, attributes, values )
    attributes.each_with_index do |attribute, index|
      value = values[ index ]
      element.attributes.get_attribute( attribute ).value.must_equal value
    end
  end

  class ViewContext
    def link_to(text, url)
      "<a href=\"#{ url }\">#{ text }</a>"
    end
  end
  
end