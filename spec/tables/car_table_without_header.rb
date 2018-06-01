class CarTableWithoutHeader < DiningTable::Table
  def define
    skip_header
    skip_footer

    column :brand
    column :number_of_doors, :footer => 'Total'
  end
end