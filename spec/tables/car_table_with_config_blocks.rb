class CarTableWithConfigBlocks < DiningTable::Table
  def define

    presenter.table_config do |config|
      config.table.class = 'my-table-class'
      config.thead.class = 'my-thead-class'
      config.tfoot.class = 'my-tfoot-class'
    end if presenter.type?(:html)

    presenter.row_config do |config, index, object|
      if index == :header
        config.tr.class = 'header-tr'
        config.th.class = 'header-th'
      elsif index == :footer
        config.tr.class = 'footer-tr'
        config.td.class = 'footer-td'
      else
        config.tr.class = index.odd? ? 'odd' : 'even'
        config.tr.class += ' lowstock' if object.stock < 10
      end
    end if presenter.type?(:html)

    column :brand, :html => { :td => { :class => 'left' } }

    number_of_doors_options = ->( config, index, object ) do
      config.td.class = 'center' unless index == :footer
      config.td.class += ' five_doors' if object && object.number_of_doors == 5
    end
    column :number_of_doors, :footer => 'Total', :html => number_of_doors_options

    column :stock, :footer => lambda { h.link_to("Total: #{ collection.map(&:stock).inject(&:+) }", '#') }
  end
end