# dining-table

dining-table was inspired by the (now unfortunately unmaintained) [table_cloth](https://github.com/bobbytables/table_cloth) gem. 
This gem is definitely not a drop-in replacement for [table-cloth](https://github.com/bobbytables/table_cloth), it aims to be less dependent on Rails 
(no Rails required to use `dining-table`) and more flexible.
In addition, it not only supports HTML output but you can output tabular data in csv or xlsx formats as well.

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

The default presenter is HTML (i.e. `DiningTable::Presenters::HTMLPresenter`), so `CarTable.new(@cars, self).render` will generate a table in HTML.
When defining columns, you can specify options that apply only when using a certain presenter. For example, here we provide css classes for `td` and `th` 
elements for some columns in the html table:

```ruby
class CarTable < DiningTable::Table
  def define
    column :brand
    column :number_of_doors, html: { td_options: { class: 'center' }, th_options: { class: :center } }
    column :stock, html: { td_options: { class: 'center' }, th_options: { class: :center } }
  end
end
```

The same table class can also be used with other presenters (csv, xlsx or a custom presenter), but the options will only be in effect when using the HTML presenter.

By instantiating the presenter yourself it is possible to specify options. For example:

```ruby
<%= CarTable.new(@cars, self, presenter: DiningTable::Presenters::HTMLPresenter.new( class: 'table table-bordered' )).render %>
```

It is also possible to wrap the table in another tag (a div for instance):

```ruby
<%= CarTable.new(@cars, self, 
                 presenter: DiningTable::Presenters::HTMLPresenter.new( class: 'table table-bordered',
                                                                        wrap: { tag: :div, class: 'table-responsive' } )).render %>
```

Both of these html options are usually best set as defaults, see [Configuration](#configuration) 

### CSV

`dining-table` can also generate csv files instead of HTML tables. In order to do that, specify the presenter when instantiating the table object. You could do
the following in a Rails controller action, for instance:

```ruby
def export_csv
  collection = Car.order(:brand)
  csv = CarTable.new( collection, nil, :presenter => DiningTable::Presenters::CSVPresenter.new ).render
  send_data( csv, :filename => 'export.csv', :content_type => "text/csv" )
end
```

The CSV Presenter uses the CSV class from the Ruby standard library. Options passed in through the :csv key will be passed on to `CSV.new`:

```ruby
csv = CarTable.new( collection, nil, :presenter => DiningTable::Presenters::CSVPresenter.new( csv: { col_sep: ';' } ) ).render
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
CarTable.new( collection, nil, :presenter => DiningTable::Presenters::ExcelPresenter.new( sheet ) ).render
```

## Configuration <a name="configuration"></a>

You can set default options for the different presenters in an initializer (e.g. `config/initializers/dining-table.rb`):

```ruby
DiningTable.configure do |config|
  config.html_presenter.default_options = { class: 'table table-bordered table-hover',
                                            wrap: { tag: :div, class: 'table-responsive' } }
  config.csv_presenter.default_options  = { :csv => { col_sep: ';' } }
end
```

## Copyright

Copyright (c) 2016 Michaël Van Damme. See LICENSE.txt for further details.
