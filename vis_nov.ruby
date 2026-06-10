require Set

class Game
  #główna pętla gry
end

class GameState
  attr_accessor 
  #przechowuje informacje dynamiczne
  #ekwipunek, flagi, relacje, czas, rozmieszczenie
  def initialize(assets)
    @relations = {}
    @item_loc = Hash.new { |hash, key| hash[key] = [] } 
    @char_loc = Hash.new { |hash, key| hash[key] = [] } 
    @flags = Set.new
    @time = Time.new
    @Assets = assets #asset_manager
  end

  def new_day()

  end

end

class DataManager
  #zapisuje informacje dynamiczne (GameState)
end

class AssetManager
  #zapisuje i wczytuje szablony
  #będzie przechowywać informacje o szablonach
  def initialize()
    @items = []
    @rooms = []
    @characters = []
    @dialogues = Hash.new { |hash, key| hash[key] = (Hash.new { |hash, key| hash[key] = [] })  } 
    #słownik    {character_id: {room_id:[dialogues]}}
  end

  def read_assets()

  end

end

class DialogueManager
  #przechodzi przez graf dialogu, sprawdza wymagania i wywołuje efekty
  def initialize(game_state, dial)
    @game_state = game_state
    @dial = dial
  end
  
  def talk()
    akt = @dial
    while akt != nil
      akt.show()
      opt = choose_opt(akt)
      opt.apply_eff(@game_state)
      akt = opt.next_dial
    end
  end

  def choose_opt(dial)
    poss_opts = []
    licz = 1
    dial.opts.each do |opt|
      puts licz
      licz += 1
      opt.show()
      if opt.is_possible 
        poss_opts << opt
      else
        poss_opts << nil
        puts "X"
      end
    end
    puts "Wybierz opcje."
    choice = gets.chomp.to_i
    while choice>poss_opts.size or choice<=0 or poss_opts[choice]==nil
      puts "Wybierz możliwą opcję"
      choice = gets.chomp.to_i
    end
    poss_opts[choice]
  end

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

  def show()
    puts @dial
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

  def show()
    puts dial
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