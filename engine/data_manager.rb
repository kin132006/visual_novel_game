require 'yaml'
require 'set'

class DataManager
  #zapisuje informacje dynamiczne (GameState)
  def self.save(file_name, game_state)
    data = {
      "relations" => game_state.relations,
      "item_loc" => game_state.item_loc,
      "char_loc" => game_state.char_loc,
      "flags" => game_state.flags.to_a,
      "time" =>  {
        "day" => game_state.time.day,
        "round" => game_state.time.round
      },   
      "room" => game_state.room,
      "inventory" => game_state.inventory,
    }
    File.write(file_name, YAML.dump(data))
    puts "Game saved"
  end

  def self.load(file_name, game_state)
    return unless File.exist?(file_name)

    data = YAML.load_file(file_name)
    game_state.relations = data["relations"]
    game_state.item_loc = data["item_loc"]
    game_state.char_loc = data["char_loc"]
    game_state.flags = data["flags"].to_set
    if data["time"]
      game_state.time.day = data["time"]["day"]
      game_state.time.round = data["time"]["round"]
    end
    game_state.room = data["room"]
    game_state.inventory = data["inventory"]
  end
end