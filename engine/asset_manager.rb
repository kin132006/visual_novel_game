require 'yaml'
require_relative 'item'
require_relative 'room'
require_relative 'character'
require_relative 'dialogue'
require_relative 'option'

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