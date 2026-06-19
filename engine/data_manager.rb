require 'yaml'
require 'set'

class DataManager
  #zapisuje informacje dynamiczne (GameState)
  def self.load(file_name, game_state)
    data = {
      "room" => game_state.room,
      "inventory" => game_state.inventory
      #To DO
    }
    File.write(file_path, YAML.dump(data))
    puts "Game saved"
  end

  def self.save(file_name, game_state)
    #To DO
  end
end