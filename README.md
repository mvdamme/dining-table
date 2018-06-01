# dining-table
[![Build Status](https://travis-ci.org/mvdamme/dining-table.png)](https://travis-ci.org/mvdamme/dining-table)

dining-table allows you to write clean Ruby classes instead of messy view code to generate HTML tables. You can re-use the same classes to 
generate csv or xlsx output as well.

dining-table was inspired by the (now unfortunately unmaintained) [table_cloth](https://github.com/bobbytables/table_cloth) gem. 
This gem is definitely not a drop-in replacement for [table_cloth](https://github.com/bobbytables/table_cloth), it aims to be less dependent on Rails 
(no Rails required to use `dining-table`, in fact it has no dependencies (except if you chose to generate xlsx output)) and more flexible.

## Installation

Add the following to your Gemfile:

```ruby
gem 'dining-table'
```

## Basic example

A table is defined by creating a table class (usually placed in app/tables) that inherits from `DiningTable::Table` and implements the `define' method:

```ruby
class CarTable < DiningTable::Table
  def define
    column :brand
    column :number_of_doors
    column :stock
  end
end
```

In your views, you can now provide a collection of `@cars` and render the table in HTML:

```ruby
<%= CarTable.new(@cars, self).render %>
```

By default, a table will have a header with column names, and no footer. There is one row per element in the collection (`@cars` in this example), and rows are rendered in order.

## Table class

### Defining columns

Columns are defined by using `column` in the `define` method of the table class. The content of the cell is determined by calling the
corresponding method of the object: for `column :brand`, the `brand` method is called for each car in the collection, and the result is placed in the appropriate cells.
If this is not what you want, you can provide a block:

```ruby
class CarTable < DiningTable::Table
  def define
    column :brand do |object|
      object.brand.upcase
    end
  end
end
```

### Headers and footers

When you don't explicitly specify a header, the header is set using `human_attribute_name` (if the objects in the collection respond to that method). 
You can also manually specify a header:

```ruby
class CarTable < DiningTable::Table
  def define
    column :brand, header: I18n.t('car.brand') do |object|
      object.brand.upcase
    end
  end
end
```

The custom header can be a string, but also a lambda or a proc.

If for some reason you don't want a header, call `skip_header`:

```ruby
class CarTable < DiningTable::Table
  def define
    skip_header
    column :brand
  end
end
```

By default, `dining-table` doesn't add a footer to the table, except when at least one column explicitly specifies a footer:

```ruby
class CarTable < DiningTable::Table
  def define
    column :brand
    column :stock, footer: lambda { "Total: #{ collection.sum(&:stock) }" }
  end
end
```

Please note how the collection passed in when creating the table obect (`@cars` in `CarTable.new(@cars, self)`) is available as `collection`.

Similarly to `skip_header`, if for some reason you don't want a footer (even though at least one column defines one), call `skip_footer`:

```ruby
class CarTable < DiningTable::Table
  def define
    skip_footer
    column :brand, footer: 'Footer'
  end
end
```

### Links and view helpers

When rendering the table in a view using `<%= CarTable.new(@cars, self).render %>`, the `self` parameter is the view context. It is made available through the `h` 
method (or the `helpers` method if you prefer to be more explicit). You can use `h` to get access to methods like Rails' `link_to`, path helpers, and view helpers:

```ruby
class CarTable < DiningTable::Table
  def define
    column :brand do |object|
      h.link_to( object.brand, h.car_path(object) )
    end
    column :stock do |object|
      h.number_with_delimiter( object.stock )
    end
  end
end
```

You can also use `h` in headers or footers:

```ruby
class CarTable < DiningTable::Table
  def define
    column :brand, header: h.link_to('Brand', h.some_path)
  end
end
```

When you want to render a table outside of a view (or when rendering csv or xlsx tables, see further) you have the following options:
* Pass in `nil` if you don't use the `h` helper in any column: `CarTable.new(@cars, nil).render`
* If you do use `h`, pass in an object that responds to the methods you use. This might be a Rails view context, or any other object:

```ruby
# in app/tables/car_table.rb
class CarTable < DiningTable::Table
  def define
    column :brand do |object|
      h.my_helper( object.brand )
    end
  end
end

# somewhere else
class FakeViewContext
  def my_helper(a)
    a
  end
end

# when rendering
cars = Car.order(:brand)
CarTable.new(cars, FakeViewContext.new).render
```

### Actions

In the case of HTML tables, one often includes an actions column with links to show, edit, delete, etc. the object. While you can do that using a regular column 
it is easier using a special actions column:

```ruby
class CarTable < DiningTable::Table
  def define
    column :brand
    actions header: I18n.t('shared.action') do |object|
      action { |object| h.link_to( I18n.t('shared.show'), h.car_path(object) ) }
      action { |object| h.link_to( I18n.t('shared.edit'), h.edit_car_path(object) ) if object.editable? }
    end
  end
end
```

### Options

When creating the table object to render, you can pass in an options hash:

```ruby
<%= CarTable.new(@cars, self, admin: current_user.admin? ).render %>
```

The passed in options are available as `options` when defining the table. One example of where this is useful is hiding certain columns or actions from non-admin users:

```ruby
class CarTable < DiningTable::Table
  def define
    admin = options[:admin]
  
    column :brand
    column :number_of_doors
    column :stock if admin
    actions header: I18n.t('shared.action') do |object|
      action { |object| h.link_to( I18n.t('shared.show'), h.car_path(object) ) }
      action { |object| h.link_to( I18n.t('shared.edit'), h.edit_car_path(object) ) if admin }
    end
  end
end
```

## Presenters

### HTML

#### Introduction

The default presenter is HTML (i.e. `DiningTable::Presenters::HTMLPresenter`), so `CarTable.new(@cars, self).render` will generate a table in HTML.
When defining columns, you can specify options that apply only when using a certain presenter. For example, here we provide css classes for `td` and `th` 
elements for some columns in the html table:

```ruby
class CarTable < DiningTable::Table
  def define
    column :brand
    column :number_of_doors, html: { td: { class: 'center' }, th: { class: 'center' } }
    column :stock, html: { td: { class: 'center' }, th: { class: 'center' } }
  end
end
```

The same table class can also be used with other presenters (csv, xlsx or a custom presenter), but the options will only be in effect when using the HTML presenter.

#### Presenter configuration

By instantiating the presenter yourself it is possible to specify options for a specific table. Using the `:tags` key you can specify
options for all HTML tags used in the table. Example:

```ruby
<%= CarTable.new(@cars, self, 
                 presenter: DiningTable::Presenters::HTMLPresenter.new( 
                   tags: { table: { class: 'table table-bordered', id: 'car_table' }, 
                           tr: { class: 'car_table_row' } } )).render %>
```
In the above example, we specify the CSS class and HTML id for the table, and the CSS class to be used for all rows in the table.
The supported HTML tags are: `table`, `thead`, `tbody`, `tfoot`, `tr`, `th`, `td`.

It is also possible to wrap the table in another tag (a div for instance), and specify options for this tag:

```ruby
<%= CarTable.new(@cars, self, 
                 presenter: DiningTable::Presenters::HTMLPresenter.new( 
                   tags: { table: { class: 'table table-bordered', id: 'car_table' }, 
                   wrap: { tag: :div, class: 'table-responsive' } )).render %>
```

Most of the html options are usually best set as defaults, see [Configuration](#configuration).

Note that configuration information provided to the presenter constructor is added to the default configuration,
it doesn't replace it. This means you can have the default configuration define the CSS class for the
table tag, for instance, and add the html id attribute when initializing the presenter, or from inside the
table definition.

#### Configuration inside the table definition

It is possible to specify or modify the configuration from within the table definition. This allows you to use custom
CSS classes, ids, etc. per row or even per cell. Example:

```ruby
class CarTableWithConfigBlocks < DiningTable::Table
  def define
    table_id = options[:table_id]  # custom option, see 'Options' above

    presenter.table_config do |config|
      config.table.class = 'table-class'
      config.table.id    = table_id || 'table-id'
      config.thead.class = 'thead-class'
    end if presenter.type?(:html)

    presenter.row_config do |config, index, object|
      if index == :header
        config.tr.class = 'header-tr'
        config.th.class = 'header-th'
      elsif index == :footer
        config.tr.class = 'footer-tr'
      else  # normal row
        config.tr.class = index.odd? ? 'odd' : 'even'
        config.tr.class += ' lowstock' if object.stock < 10
      end
    end if presenter.type?(:html)

    column :brand
    column :stock, footer: 'Footer text'
  end
end
```
This example shows how to use `presenter.table_config` to set the configuration for (in this case) the `table` and `thead`tags. The block you use with `table_config`
is called once, when the table is being rendered. A configuration object is passed in that allows you to set any HTML attribute of the
seven supported tags. 

Note that the configuration object already contains the pre-existing configuration information (coming
from either the presenter initialisation and/or from the global configuration), so you can refine the configuration in the block
instead of having to re-specify it in full. This means you can easily add CSS classes without knowledge of previously existing
configuration:
```ruby
presenter.table_config do |config|
  config.table.class += ' my-table-class'
end if presenter.type?(:html)
```
Per row configuration can be specified with `presenter.row_config`. The block used with this method is called once for each row being
rendered, and receives three parameters: the configuration object (identical as with `table_config`), and index value, and the object 
containing the data being rendered in this row. 
The index value is equal to the row number of the row being rendered (starting at zero), except for the header and footer rows, in which case it
is equal to `:header` and `:footer`, respectively. `object` is the current object being rendered (`nil` for the header and footer row). 
As above, the passed in configuration object already contains the configuration which is in effect before calling the block.

#### Per cell configuration

As shown above, you can specify per column configuration using a hash:

```ruby
class CarTable < DiningTable::Table
  def define
    column :number_of_doors, html: { td: { class: 'center' }, th: { class: 'center' } }
  end
end
```
For each column, the per column configuration is merged with the row configuration (see `presenter.row_config` above) before
cells from the column are rendered.

Sometimes, you might want to specify the configuration per cell, for instance to add a CSS class for cells with a certain content.
This is possible by supplying a lamba or proc instead of a hash: 

```ruby
class CarTable < DiningTable::Table
  def define
    number_of_doors_options = ->( config, index, object ) do
      config.td.class = 'center'
      config.td.class += ' five_doors' if object && object.number_of_doors == 5
    end
    column :number_of_doors, html: number_of_doors_options
  end
end
```
The arguments provided to the lambda or proc are the same as in the case of `presenter.row_config`.

### CSV

`dining-table` can also generate csv files instead of HTML tables. In order to do that, specify the presenter when instantiating the table object. You could do
the following in a Rails controller action, for instance:

```ruby
def export_csv
  collection = Car.order(:brand)
  csv = CarTable.new( collection, nil, presenter: DiningTable::Presenters::CSVPresenter.new ).render
  send_data( csv, filename: 'export.csv', content_type: "text/csv" )
end
```

The CSV Presenter uses the CSV class from the Ruby standard library. Options passed in through the :csv key will be passed on to `CSV.new`:

```ruby
csv = CarTable.new( collection, nil, presenter: DiningTable::Presenters::CSVPresenter.new( csv: { col_sep: ';' } ) ).render
```

CSV options can also be set as defaults, see [Configuration](#configuration) 

It can often be useful to use the same table class with both html and csv presenters. Usually, you don't want the action column in your csv file. 
You can easilly omit it when the presenter is not HTML:

```ruby
class CarTable < DiningTable::Table
  def define
    column :brand
    actions header: I18n.t('shared.action') do |object|
      action { |object| h.link_to( I18n.t('shared.show'), h.car_path(object) ) }
      action { |object| h.link_to( I18n.t('shared.edit'), h.edit_car_path(object) ) }
    end if presenter.type?(:html)
  end
end
```

Note that you also have access to the `presenter` inside column blocks, so if necessary you can adapt a column's content accordingly:

```ruby
class CarTable < DiningTable::Table
  def define
    column :brand do |object|
      if presenter.type?(:html)
        h.link_to( object.brand, h.car_path(object) )
      else
        object.brand  # no link for csv and xlsx
      end
    end
  end
end
```

### Excel (xlsx)

The Excel presenter depends on [axlsx](https://github.com/randym/axlsx). Note that `dining-table` doesn't require `axlsx`, you have to add it to 
your Gemfile yourself if you want to use the Excel presenter.

In order to use the Excel presenter, pass it in as a presenter and provide an axlsx worksheet:

```ruby
collection = Car.order(:brand)
# sheet is the axlsx worksheet in which the table will be rendered
CarTable.new( collection, nil, presenter: DiningTable::Presenters::ExcelPresenter.new( sheet ) ).render
```

## Custom column classes

You can write your own column classes and use them for specific columns. For instance, the following column class will format a date using `I18n`:

```ruby
class DateColumn < DiningTable::Columns::Column
  def value(object)
    val = super
    I18n.l( val ) if val
  end
end
```

A column class has to be derived from `DiningTable::Columns::Column` and implement the `value` method. The object passed in is the object in the 
collection for which the current line is being rendered. If you don't have too many custom column classes, an easy place to put the code is in an initializer 
(e.g. `config/initializers/dining-table.rb`).

You can use custom column classes as follows:

```ruby
class CarTable < DiningTable::Table
  def define
    column :fabrication_date, class: DateColumn
  end
end
```

## Configuration <a name="configuration"></a>

You can set default options for the different presenters in an initializer (e.g. `config/initializers/dining-table.rb`):

```ruby
DiningTable.configure do |config|
  config.html_presenter.default_options = { tags: { table: { class: 'table table-bordered' }, 
                                                    thead: { class: 'header' } },
                                            wrap: { tag: :div, class: 'table-responsive' } }
  config.csv_presenter.default_options  = { csv: { col_sep: ';' } }
end
```

## Copyright

Copyright (c) 2018 Michaël Van Damme. See LICENSE.txt for further details.
