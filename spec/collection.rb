class Car < Struct.new(:brand, :type, :number_of_doors, :stock, :launch_date)

  COLLECTION = [
    [ 'Audi',    'A4',         3, 100, Date.new(2016, 1, 1) ],
    [ 'Citroën', 'C4 Picasso', 5, 150, Date.new(2016, 2, 1) ],
    [ 'Ferrari', 'F12',        3, 2,   Date.new(2016, 3, 1) ]
  ]

  def self.collection
    COLLECTION.map do |data|
      self.new( *data )
    end
  end

end

class CarWithHumanAttributeName < Car

  def self.human_attribute_name(attribute)
    attribute.to_s.gsub('_', ' ').capitalize
  end

end
