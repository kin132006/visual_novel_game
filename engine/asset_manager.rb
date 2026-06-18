require 'yaml'
require_relative 'item'
require_relative 'room'
require_relative 'character'
require_relative 'dialogue'
require_relative 'option'
require_relative 'effect'
require_relative 'requirement'

class AssetManager
  attr_reader :items, :rooms, :characters, :dialogues
  #zapisuje i wczytuje szablony
  #będzie przechowywać informacje o szablonach
  def initialize(base_path)
    @base_path = base_path

    @items = {}
    @rooms = {}
    @characters = {}

    @reqs = {}
    @effects = {}
    @options = {}
    
    @dialogues = Hash.new { |hash, key| hash[key] = (Hash.new { |hash, key| hash[key] = [] })  } 
    #słownik    {character_id(name): {room_id(name):[dialogues]}}
  end

  def read_assets()
    @dial = {}
    read_items
    read_characters
    read_rooms
    read_reqs
    read_effects  
    read_opts
    read_dialogues
    link_everything    
  end

  def read_items()
    items_file = "#{@base_path}/assets/items.yaml"
    if File.exist?(items_file)

      raw_items = YAML.load_file(items_file)  
      raw_items.each do |data|
        @items[data['id']] = Item.new(data["name"], data["description"])
      end
    end
  end

  def read_rooms()
    rooms_file = "#{@base_path}/assets/rooms.yaml"
    if File.exist?(rooms_file)

      raw_items = YAML.load_file(rooms_file)  
      raw_items.each do |data|
        @rooms[data['id']] = Room.new(data["name"], data["description"])
      end
    end
  end

  def read_characters()
    characters_file = "#{@base_path}/assets/characters.yaml"
    if File.exist?(characters_file)

      raw_items = YAML.load_file(characters_file)  
      raw_items.each do |data|
        @characters[data['id']] = Character.new(data["name"], data["description"])
      end

    end
  end

  def read_reqs()
    reqs_file = "#{@base_path}/assets/requirements.yaml"
    if File.exist?(reqs_file)
      raw_data = YAML.load_file(reqs_file)
      raw_data.each do |data|
        @reqs[data['id']] = create_req(data)
      end      
    end  
  end

  def read_effects()
    effects_file = "#{@base_path}/assets/effects.yaml"
    if File.exist?(effects_file)
      raw_data = YAML.load_file(effects_file)
      raw_data.each do |data|
        @effects[data['id']] = create_effect(data)
      end      
    end  
  end

  def read_opts()
    #TO DO
  end

  def read_dialogues()
    #TO DO
  end

  def link_everything()
    #TO DO
  end

  def create_req(data)
    case data["type"]
    when "location"
      LocationRequirement.new(data['room_id'])
    when "min_relation"
      MinRelationRequirement.new(data["char_id"], data["value"])
    else
      raise "Nieznany typ wymagania: #{data["type"]}"
    end
  end

  def create_effect(data)
    case data["type"]
    when "relation"
      Relation.new(data['char_id'], data['value'])
    when "add_item"
      AddItem.new(data["item_id"])
    else
      raise "Nieznany typ wymagania: #{data["type"]}"
    end
  end

end