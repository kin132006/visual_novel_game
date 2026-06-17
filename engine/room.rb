
class Room
  attr_reader :name, :description
  def initialize(name,desc)
    @name = name
    @description = desc
  end

  def description()
    puts @description
  end
end