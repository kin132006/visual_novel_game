
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