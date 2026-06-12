require Set

class Game
  #główna pętla gry
  def initialize()
    @file_name = ""
    @asset_manager = AssetManager.new()
    asset_manager.read_assets()
    @game_state = GameState.new(asset_manager)
  end

  def start()

  end

  def new_game()
    #uzupełnienie paru wartości

    self.game_loop()
  end

  def continue_game()
    DataManager.load(file_name)
    self.game_loop()
  end

  def game_loop()
    while true
      self.choice()
    end
  end

  def choice

  end

  def change_room(room)
    @game_state.room = room
    self.room_desc()
  end

  def room_desc()
    puts "You are in #{@game_state.room}."
    puts "Characters: #{@game_state.char_loc[room].join(", ")}."
    puts "Items: #{@game_state.item_loc[room].join(", ")}."
  end

  def take_item(item, room)
    @game_state.inventory << item.name
    puts "#{item.name} added to inventory."
    @game_state.item_loc[room.name].delete(item.name)
  end

  def talk(character)
    dial = self.find_dial(character)
    if !dial
      puts "Nie masz o czym rozmawiać"
    else
      dialogue_manager = DialogueManager.new(game_state, dial)
      dialogue_manager.talk
      @game_state.time.next_round()
    end
  end

  def find_dial(character) #character name
    room = game_state.room #room name
    dialogues = asset_manager.dialogues[character][room]
    chosen = nil
    dialogues.each do |dial|
      if dial.is_possible(@game_state)
        chosen = dial
        break
      end
    end
    chosen
  end

  def describe(object) #character, item, room
    object.description()
  end

end

class GameState
  attr_accessor 
  #przechowuje informacje dynamiczne
  #ekwipunek, flagi, relacje, czas, rozmieszczenie
  def initialize(assets)
    @relations = Hash.new { |hash, key| hash[key] = 0 } 
    @item_loc = Hash.new { |hash, key| hash[key] = [] } # room:items
    @char_loc = Hash.new { |hash, key| hash[key] = [] } # room:chars
    @flags = Set.new
    @time = Time.new
    @room = nil
    @inventory = []
    @Assets = assets #asset_manager
  end

  def new_day() #losuje na nowo przedmioty w pokojach

  end
end

class DataManager
  #zapisuje informacje dynamiczne (GameState)
  def self.load(file_name, game_state)

  end

  def self.save(file_name, game_state)

  end
end

class AssetManager
  #zapisuje i wczytuje szablony
  #będzie przechowywać informacje o szablonach
  def initialize()
    @items = []
    @rooms = []
    @characters = []
    @dialogues = Hash.new { |hash, key| hash[key] = (Hash.new { |hash, key| hash[key] = [] })  } 
    #słownik    {character_id(name): {room_id(name):[dialogues]}}
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

  def description()
    puts @description
  end

end

class Room
  def initialize(name,desc)
    @name = name
    @description = desc
  end

  def description()
    puts @description
  end
end

class Item
  def initialize(name,desc)
    @name = name
    @description = desc
  end

  def description()
    puts @description
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