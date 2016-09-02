class CarTable < DiningTable::Table
  def define
    column :brand
    column :type if presenter.type?(:csv)
    column :number_of_doors
    column :stock
  end
end