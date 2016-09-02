class CarTableWithFooter < DiningTable::Table
  def define
    column :brand
    column :number_of_doors, :footer => 'Total'
    column :stock, :footer => lambda { h.link_to("Total: #{ collection.map(&:stock).inject(&:+) }", '#') }
  end
end