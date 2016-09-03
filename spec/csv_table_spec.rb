require 'spec_helper'
require 'collection'
require 'rexml/document'
Dir["#{File.dirname(__FILE__)}/tables/**/*.rb"].each {|file| require file }


describe 'CSVTableSpec' do
  before do
    @cars = CarWithHumanAttributeName.collection
    @presenter = DiningTable::Presenters::CSVPresenter.new
  end
  
  it "correctly renders a basic table" do
    csv = CarTable.new(@cars, nil, :presenter => @presenter).render
    data = CSV.parse(csv)
    check_data( data )
  end

  it "respects csv options" do
    @presenter = DiningTable::Presenters::CSVPresenter.new( :csv => { :col_sep => ';' } )
    csv = CarTable.new(@cars, nil, :presenter => @presenter).render
    data = CSV.parse(csv)
    data.first.length.must_equal 1  # wrongly parsed due to using comma as a separator
    data = CSV.parse(csv, :col_sep => ';')
    check_data( data )
  end

  it "respects global csv options" do
    DiningTable.configure do |config|
      config.csv_presenter.default_options = { :csv => { :col_sep => ';' } }
    end
    @presenter = DiningTable::Presenters::CSVPresenter.new
    csv = CarTable.new(@cars, nil, :presenter => @presenter).render
    data = CSV.parse(csv)
    data.first.length.must_equal 1  # wrongly parsed due to using comma as a separator
    data = CSV.parse(csv, :col_sep => ';')
    check_data( data )
    # reset configuration for other specs
    DiningTable.configure do |config|
      config.csv_presenter.default_options = {  }
    end
  end
  
  def check_data( data )
    data.first.must_equal ["Brand", "Type", "Number of doors", "Stock"]
    @cars.each_with_index do |car, index|
      line = [ :brand, :type, :number_of_doors, :stock ].map do |item|
        car.send(item).to_s
      end
      data[index + 1].must_equal line
    end
  end

end