require Set

class Game
  #główna pętla gry
  def initialize(title)
    @title
    @file_name = ""
    @asset_manager = AssetManager.new()
    asset_manager.read_assets()
    @game_state = GameState.new(asset_manager)
  end

  def start()
    puts "Welcome to #{@title}" 
    while true
      puts "Choose what you want to do:"
      puts "1. New game"
      puts "2. Continue game"
      puts "3. quit"

      print "> "
      choice = gets.chomp.to_i

      if choice == 1
        puts "NEW GAME"
        puts "Choose a name for your save file"
        print "> "
        @file_name = gets.chomp.strip.gsub(' ', '_')

        if @file_name.empty?
          @file_name = "save_#{Time.now.to_i}"
        end

        puts "Creating new save file as #{@file_name}.json"
        new_game()
        break

      elsif choice == 2
        puts "CONTINUE GAME"
        #wybór z listy
        Dir.mkdir("saves") unless Dir.exist?("saves")
        saves = Dir.glob("saves/*.json").map { |path| File.basename(path, ".json") }
        if saves.empty?
          puts "No save files found! Start a new game."
          next
        end
        puts "Choose your save file"
        saves.each_with_index do |name, idx|
          puts "#{idx+1}. #{name}"
        end 
        puts "#{saves.size+1}. Go back to main menu"

        print "> "
        save_choice = gets.chomp.to_i

        if save_choice == saves.size + 1
          next
        elsif save_choice > 0 && save_choice <= saves.size
          @file_name = saves[save_choice-1]
          puts "Loading save_file: #{file_name}..."
          continue_game()
        else
          puts "Invalid save file selection!"
        end
      elsif choice == 3 
        exit
      else
        "Invalid input"
      end
    end
  end

  def new_game()
    #uzupełnienie paru wartości w game_state
    # trzeba uzupełnić tablice i słowniki w game_state, żeby miały podstawowe wartości

    self.game_loop()
  end

  def continue_game()
    DataManager.load(@file_name)
    self.game_loop()
  end

  def game_loop()
    while true
      self.choice()
    end
  end

  def choice
    room = @game_state.room
    puts "You are in #{room}."
    puts "Choose an action"
    puts "1. Describe the room"
    puts "2. Describe item"
    puts "3. Describe character"
    puts "4. Take item"
    puts "5. Talk with character"
    puts "6. Go to another room"
    puts "7. Save"
    puts "8. Go back to menu"
    puts "9. Exit"

    choice = gets.chomp_to_i
    case choice 
    when 1
      room_desc
    when 2
      puts "choose an item to describe"
      items = @game_state.item_loc[room] 
      items.each_with_index do |name, idx|
        puts "#{idx+1}. #{name}"
      end 
      puts "#{items.size+1}. Go back"
      print "> "
      choice = gets.chomp.to_i
      if choice == items.size + 1
        next
      elsif choice>0 && choice<= items.size
        describe(@asset_manager.items[items[choice]])
      else
        puts "Invalid choice"
        next
      end
    when 3
      puts "choose a character to describe"
      characters = @game_state.char_loc[room] 
      characters.each_with_index do |name, idx|
        puts "#{idx+1}. #{name}"
      end 
      puts "#{characters.size+1}. Go back"
      print "> "
      choice = gets.chomp.to_i
      if choice == characters.size + 1
        next
      elsif choice>0 && choice<= characters.size
        describe(@asset_manager.characters[characters[choice]])
      else
        puts "Invalid choice"
        next
      end
    when 4
      puts "choose an item to take"
      items = @game_state.item_loc[room] 
      items.each_with_index do |name, idx|
        puts "#{idx+1}. #{name}"
      end 
      puts "#{items.size+1}. Go back"
      print "> "
      choice = gets.chomp.to_i
      if choice == items.size + 1
        next
      elsif choice>0 && choice<= items.size
        take_item(items[choice], room)
      else
        puts "Invalid choice"
        next
      end
    when 5
      puts "choose a character to talk to"
      characters = @game_state.char_loc[room] 
      characters.each_with_index do |name, idx|
        puts "#{idx+1}. #{name}"
      end 
      puts "#{characters.size+1}. Go back"
      print "> "
      choice = gets.chomp.to_i
      if choice == characters.size + 1
        next
      elsif choice>0 && choice<= characters.size
        talk(characters[choice])
      else
        puts "Invalid choice"
        next
      end
    when 6
      puts "choose a room to go to"
      rooms = @asset_manager.rooms.keys
      rooms.each_with_index do |name, idx|  
        puts "#{idx+1}. #{name}"
      end 
      puts "#{room.keys.size+1}. Go back"
      print "> "
      choice = gets.chomp.to_i
      if choice == rooms.size + 1
        next
      elsif choice>0 && choice<= rooms.size
        talk(rooms[choice])
      else
        puts "Invalid choice"
        next
      end
    when 7
      DataManager.save(@file_name, @game_state)
      puts "Saved progress to #{@file_name}"
    when 8 
      start()
      break
    when 9
      exit
    else
      puts "Invalid choice"
    end
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

  def take_item(item, room) #item_id, room_id
    @game_state.inventory << item
    puts "#{item} added to inventory."
    @game_state.item_loc[room].delete(item)
  end

  def talk(character)
    dial = self.find_dial(character) #character name
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
    @time = Time.new(1, 1)
    @room = nil     #id pokoju
    @inventory = []   #tablica id itemów
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
    @items = {}
    @rooms = {}
    @characters = {}
    @dial = Hash.new { |hash, key| hash[key] = nil}
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
      print "#{licz}. "
      licz += 1
      opt.show()
      if opt.is_possible 
        poss_opts << opt
      else
        poss_opts << nil
        print " X"
        puts ""
      end
    end
    puts "Choose an option"
    choice = gets.chomp.to_i
    while choice>poss_opts.size or choice<=0 or poss_opts[choice]==nil
      print "Invalid option, choose again: "
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
  attr_reader :name, :description
  def initialize(name,desc)
    @name = name
    @description = desc
  end

  def description()
    puts @description
  end

end

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

class Item
  attr_reader :name, :description
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
    print @dial
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
    print dial
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

class Requirement
  def initialize()
    raise "NotImplemented"
  end

  def fullfilled?(game_state)
    raise "NotImplemented"
  end
end