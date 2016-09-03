class CarTableWithOptions < DiningTable::Table
  def define
    column :brand, :html => { :td_options => { class: 'center' }, :th_options => { class: :center } } do |object|
      object.brand.upcase
    end
    column :stock, :html => { :td_options => { class: 'left' }, :th_options => { class: :left } }
    column :launch_date if options[:with_normal_launch_date]
    column :launch_date, :class => DateColumn if options[:with_date_column_launch_date]
  end
end