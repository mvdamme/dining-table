# note that this custom class is specific for testing (value contains minitest assertions)
class DateColumn < DiningTable::Columns::Column
  def value(object)
    val = super
    val.class.name.must_equal 'Date'  # make sure an actual object is returned, not a string representation
    self.class.localize( val ) if val
  end
  
  def self.localize(date)
    "#{ date.day }/#{ date.month }/#{ date.year }"
  end
end
