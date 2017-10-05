class Pipe
  TYPE='pipes'
  TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE', 'on', 'ON', 'yes', 'YES', 'Yes'].freeze
  attr_accessor :name, :group
  
  def self.all
    YAML.load(File.read(SDB))[TYPE] rescue {}
  end

  def self.find id
    Pipe.new all[id.to_i]
  end

  def self.each &block
    all.map{|_,h| Pipe.new(h)}.each(&block)
  end


  def initialize params = {}
    params.each do |k,v|
      public_send "#{k}=", v
    end
  end

  def pin;@pin.to_i; end
  def pin= val
    @pin = val.to_i
  end

  def id
    @id.to_i if @id
  end
  def id= val
    @id = val.to_i
  end

  def attributes
    {"id"=>id,"pin"=>pin,"name"=>name,"group"=>group}
  end

  def [](key)
    attributes[key.to_s]
  end

  def save
    self.id = Time.now.to_i if id.nil?
    data = YAML.load(File.read(SDB)) rescue {}
    data[TYPE] ||= {}
    data[TYPE][id] = attributes
    File.write(SDB, YAML.dump(data))
  end

  def active?
    `fast-gpio read #{pin}`.split(': ').last.strip == '1'.freeze
  rescue Exception => e
    false
  end
  alias active active?

  def active= val
    `fast-gpio set #{pin} #{TRUE_VALUES.include?(val) ? 1 : 0}`.split(': ').last.strip rescue false
  end

end