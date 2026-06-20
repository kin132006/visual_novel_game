
class Requirement
  def initialize()
    raise "NotImplemented"
  end

  def fullfilled?(game_state)
    raise "NotImplemented"
  end
end

class LocationRequirement < Requirement
  attr_reader :room_id
  def initialize(loc_id)
    @room_id = loc_id
  end

  def fullfilled?(game_state)
    @room_id == "any" || game_state.room == @room_id
  end
end

class  MinRelationRequirement < Requirement
  attr_reader :char, :val
  def initialize(char_id, val)
    @char = char_id
    @val = val
  end

  def fullfilled?(game_state)
    game_state.relations[@char] >= @val
  end
end

class  FlagRequirement < Requirement
  attr_reader :flag
  def initialize(flag)
    @flag = flag
  end

  def fullfilled?(game_state)
    game_state.flags.include?(@flag)
  end
end

class  HasItemRequirement < Requirement
  attr_reader :item
  def initialize(item)
    @item = item
  end

  def fullfilled?(game_state)
    game_state.inventory.include?(@item)
  end
end