require_relative 'game_state'
require_relative 'asset_manager'
require_relative 'data_manager'

class Game
  #główna pętla gry
  def initialize(title)
    @title
    @file_name = ""
    @asset_manager = AssetManager.new()
    asset_manager.read_assets()
    @game_state = GameState.new(asset_manager)
    @base_path = "games/#{title}"
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