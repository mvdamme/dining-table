class CarTableWithActions < DiningTable::Table
  def define
    column :brand
    column :number_of_doors
    actions :header => 'Action', :html => { :td_options => { class: 'left' }, :th_options => { class: :left } } do |object|
      action { |object| h.link_to( 'Show', '#show' ) }
      action { |object| h.link_to( 'Edit', '#edit' ) }
    end
  end
end