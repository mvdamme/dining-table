class CarTableWithOptions < DiningTable::Table
  def define
    column :brand, :html => { :td_options => { class: 'center' }, :th_options => { class: :center } } do |object|
      object.brand.upcase
    end
    column :stock, :html => { :td_options => { class: 'left' }, :th_options => { class: :left } }
  end
end