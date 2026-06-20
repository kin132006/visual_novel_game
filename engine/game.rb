require_relative 'game_state'
require_relative 'asset_manager'
require_relative 'data_manager'
require_relative 'dialogue_manager'

class Game
  #główna pętla gry
  def initialize(title)
    @title = title
    @base_path = File.expand_path("../../games/#{@title}", __FILE__)
    @file_name = ""
    @asset_manager = AssetManager.new(@base_path)
    @asset_manager.read_assets()
    @game_state = GameState.new(@asset_manager)
    
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
          @file_name = "save_#{::Time.now.to_i}"
        end
        
        saves_dir = "#{@base_path}/saves"
        Dir.mkdir(saves_dir) unless Dir.exist?(saves_dir)

        @file_name = "#{saves_dir}/#{@file_name}.yaml"
        puts "Creating new save file at #{@file_name}.yaml"
        new_game()
        break

      elsif choice == 2
        puts "CONTINUE GAME"
        saves_dir = "#{@base_path}/saves"
        Dir.mkdir(saves_dir) unless Dir.exist?(saves_dir)
        saves = Dir.glob("#{saves_dir}/*.yaml").map { |path| File.basename(path, ".yaml") }
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
          @file_name = "#{saves_dir}/#{saves[save_choice-1]}.yaml"
          puts "Loading save_file: #{@file_name}..."
          continue_game()
          break
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
    @game_state.set_default()
    @game_state.set_positions()
    DataManager.save(@file_name, @game_state)
    game_loop()
  end

  def continue_game()
    DataManager.load(@file_name, @game_state)
    self.game_loop()
  end

  def game_loop()
    while true
      choice()
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

    choice = gets.chomp.to_i
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
        puts "going back"
      elsif choice>0 && choice<= items.size
        describe(@asset_manager.items[items[choice-1]])
      else
        puts "Invalid choice"
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
        puts "going back"
      elsif choice>0 && choice<= characters.size
        describe(@asset_manager.characters[characters[choice-1]])
      else
        puts "Invalid choice"
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
        puts "going back"
      elsif choice>0 && choice<= items.size
        take_item(items[choice-1], room)
      else
        puts "Invalid choice"
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
        puts "going back"
      elsif choice>0 && choice<= characters.size
        talk(characters[choice-1])
      else
        puts "Invalid choice"
      end
    when 6
      puts "choose a room to go to"
      rooms = @asset_manager.rooms.keys
      rooms.each_with_index do |name, idx|  
        puts "#{idx+1}. #{name}"
      end 
      puts "#{rooms.size+1}. Go back"
      print "> "
      choice = gets.chomp.to_i
      if choice == rooms.size + 1
        puts "going back"
      elsif choice>0 && choice<= rooms.size
        change_room(rooms[choice-1])
      else
        puts "Invalid choice"
      end
    when 7
      DataManager.save(@file_name, @game_state)
      puts "Saved progress to #{@file_name}"
    when 8 
      start()
    when 9
      exit
    else
      puts "Invalid choice"
    end
  end

  def change_room(room)
    @game_state.room = room
    @game_state.time.next_round(@game_state)
    self.room_desc()
  end

  def room_desc()
    room = @game_state.room
    puts "You are in #{room}."
    room_o = @asset_manager.rooms[room]
    room_o.description
    puts "Characters: #{@game_state.char_loc[room].join(", ")}."
    puts "Items: #{@game_state.item_loc[room].join(", ")}."
  end

  def take_item(item, room) #item_id, room_id
    @game_state.inventory << item
    puts "#{item} added to inventory."
    @game_state.item_loc[room].delete(item)
  end

  def talk(character)
    dial = find_dial(character) #character name
    if !dial
      puts "You don't have anything to talk about"
    else
      dialogue_manager = DialogueManager.new(@game_state, dial)
      dialogue_manager.talk
      @game_state.time.next_round(@game_state)
    end
  end

  def find_dial(character) #character name
    return nil unless @asset_manager.dialogues[character]

    room = @game_state.room #room name
    dialogues = (@asset_manager.dialogues[character][room] || []).dup
    if @asset_manager.dialogues[character]['any']
      dialogues.concat(@asset_manager.dialogues[character]['any'])
    end
    dialogues = dialogues.shuffle
    chosen = nil
    dialogues.each do |dial|
      if dial.is_possible?(@game_state)
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