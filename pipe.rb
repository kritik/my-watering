require 'json'
class Pipe < Sequel::Model
  TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE', 'on', 'ON', 'yes', 'YES', 'Yes'].freeze

  def active?
    JSON.parse(`fast-gpio -u read #{pin}`)['val'] == '1'.freeze
  rescue Exception => e
    false
  end
  alias active active?

  def active= val
    JSON.parse(`fast-gpio -u set #{pin} #{TRUE_VALUES.include?(val) ? 1 : 0}`) rescue false
  end

end