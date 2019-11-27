require 'dining-table'
require 'minitest/autorun'

class String
  def html_safe
    self
  end
end