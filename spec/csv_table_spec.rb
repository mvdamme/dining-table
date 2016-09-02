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
    data.first.must_equal ["Brand", "Type", "Number of doors", "Stock"]
    @cars.each_with_index do |car, index|
      line = [ :brand, :type, :number_of_doors, :stock ].map do |item|
        car.send(item).to_s
      end
      data[index + 1].must_equal line
    end
  end

end