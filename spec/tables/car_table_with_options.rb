class CarTableWithOptions < DiningTable::Table
  def define
    column :brand, :html => { :td => { class: 'center' }, :th => { class: :center } } do |object|
      object.brand.upcase
    end
    column :stock, :html => { :td => { class: 'left' }, :th => { class: :left } }
    column :launch_date if options[:with_normal_launch_date]
    column :launch_date, :class => DateColumn if options[:with_date_column_launch_date]
  end
end