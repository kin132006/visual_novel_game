
class Game
  #główna pętla gry
end

class GameState
  #przechowuje informacje dynamiczne
  #ekwipunek, flagi, relacje, czas, rozmieszczenie
end

class DataManager
  #zapisuje informacje dynamiczne (GameState)
end

class AssetManager
  #zapisuje i wczytuje szablony
  #będzie przechowywać informacje o szablonach
end

class DialogueManager
  #przechodzi przez graf dialogu, sprawdza wymagania i wywołuje efekty
end

class Time
  def initialize(day, round)
    @day = day
    @round = round
    @max_round = 10
  end

  def next_round(game_state)
    @round += 1
    if(@round==@max_round)
      @day+=1
      game_state.new_day()
    end
  end  
end

class Character
  def initialize(name,desc)
    @name = name
    @description = desc
  end
end

class Room
  def initialize(name,desc)
    @name = name
    @description = desc
  end
end

class Item
  def initialize(name,desc)
    @name = name
    @description = desc
  end
end

class Dialogue
  def initialize(id, dial, reqs, opts)
    @id = id
    @dial = dial #kwestia dialogowa
    @reqs = reqs #lista wymagań
    @opts = opts #lista opcji
  end

  def is_possible?(game_state)
    @reqs.each do |req|
      if !req.fullfilled?(game_state)
        return false
      end
    end
    return true   
  end
end

class Option
  def initialize(id, dial, reqs, effs, next_dial)
    @id = id
    @dial = dial
    @reqs = reqs
    @effs = effs
    @next_dial = next_dial
  end

  def is_possible?(game_state)
    @reqs.each do |req|
      if !req.fullfilled?(game_state)
        return false
      end
    end
    return true   
  end

  def apply_eff(game_state)
    @effs.each do |eff|
      eff.apply(game_state)
    end
end

class Effect
  def initialize()
    raise "NotImplemented"
  end

  def apply(game_state)
    raise "NotImplemented"
  end
end

class Requirements
  def initialize()
    raise "NotImplemented"
  end

  def fullfilled?(game_state)
    raise "NotImplemented"
  end
end