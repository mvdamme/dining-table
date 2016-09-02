class CarTableWithHeader < DiningTable::Table
  def define
    column :brand, :header => 'The brand'
    column :number_of_doors, :header => lambda { 'The number of doors' }
    column :stock, :header => lambda { h.link_to('Stock', 'http://www.google.com') }
  end
end