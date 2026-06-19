
class Requirement
  def initialize()
    raise "NotImplemented"
  end

  def fullfilled?(game_state)
    raise "NotImplemented"
  end
end

class LocationRequirement < Requirement
  def initialize(loc_id)
    @room_id = loc_id
  end

  def fullfilled?(game_state)
    game_state.room == @room_id
  end
end

class  MinRelationRequirement < Requirement
  def initialize(char_id, val)
    @char = char_id
    @val = val
  end

  def fullfilled?(game_state)
    game_state.relations[@char] >= @val
  end
end

class  FlagRequirement < Requirement
  def initialize(flag)
    @flag = flag
  end

  def fullfilled?(game_state)
    game_state.flags.include?(@flag)
  end
end

class  HasItemRequirement < Requirement
  def initialize(item)
    @item = item
  end

  def fullfilled?(game_state)
    game_state.inventory.include?(@item)
  end
end