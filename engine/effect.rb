
class Effect
  def initialize()
    raise "NotImplemented"
  end

  def apply(game_state)
    raise "NotImplemented"
  end
end

class AddItem < Effect
  attr_accessor :item_id
  def initialize(item_id)
    @item_id = item_id
  end

  def apply(game_state)
    game_state.inventory << @item_id
    puts "Added #{@item_id} to inventory"
  end
end

class AddFlag < Effect
  attr_accessor :flag
  def initialize(flag_id)
    @flag = flag_id
  end

  def apply(game_state)
    game_state.flags << @flag
  end
end

class RemoveItem < Effect
  attr_accessor :item_id
  def initialize(item_id)
    @item_id = item_id
  end

  def apply(game_state)
    game_state.inventory.delete(@item_id)
  end
end

class Relation < Effect
  attr_accessor :char, :val
  def initialize(char_id, val)
    @char = char_id
    @val = val
  end

  def apply(game_state)
    game_state.relations[@char] += @val
    value = ''
    if @val<0
      value = "#{@val}"
    else
      value = "+#{@val}"
    end
    puts "Relathionship with #{@char}: #{value}"
  end
end
