class CarTableWithActions < DiningTable::Table
  def define
    column :brand
    column :number_of_doors
    actions :header => 'Action', :html => { :td => { class: 'left' }, :th => { class: :left } } do |object|
      h.link_to( 'Show', '#show' )  # doesn't do anything, simply verify that h helper is available
      action { |object_| h.link_to( 'Show', '#show' ) }
      action { |object_| h.link_to( 'Edit', '#edit' ) }
    end
  end
end