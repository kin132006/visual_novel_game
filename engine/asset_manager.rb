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
    
    @dial_id = {}
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
    opts_file = "#{@base_path}/assets/options.yaml"
    if File.exist?(opts_file)
      raw_data = YAML.load_file(opts_file)
      raw_data.each do |data|
        reqs_l = []
        (data['reqs'] || []).each do |req|
          reqs_l << @reqs[req]
        end
        effects_l = []
        (data['effects'] || []).each do |eff|
          effects_l << @effects[eff]
        end
        @options[data['id']] = Option.new(data['id'],data['text'],reqs_l,effects_l,data['next_dial'])
      end      
    end  
  end

  def read_dialogues()
    dial_file = "#{@base_path}/assets/dialogues.yaml"
    if File.exist?(dial_file)
      raw_data = YAML.load_file(dial_file)
      raw_data.each do |data|
        reqs_l = []
        (data['reqs'] || []).each do |req|
          reqs_l << @reqs[req]
        end
        opts = []
        data['options'].each do |opt|
          opts << @options[opt]
        end
        @dial_id[data['id']] = Dialogue.new(data['id'],data['character'],data['text'],reqs_l,opts)
      end      
    end  
  end

  def link_everything()
    @options.values.each do |opt|
      if opt.next_dial
        opt.next_dial = @dial_id[opt.next_dial]
      end
    end

    @dial_id.values.each do |dial|
      dial.reqs.each do |req|
        if req.is_a?(LocationRequirement)
          dialogues[dial.char][req.room_id] << dial
        end
      end
    end
  end

  def create_req(data)
    case data["type"]
    when "location"
      LocationRequirement.new(data['loc_id'])
    when "min_relation"
      MinRelationRequirement.new(data["char_id"], data["val"])
    when "flag"
      FlagRequirement.new(data["flag"])
    when "has_item"
      HasItemRequirement.new(data["item_id"])
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
    when "add_flag"
      AddFlag.new(data["flag"])
    when "remove_item"
      RemoveItem.new(data["item_id"])
    else
      raise "Nieznany typ wymagania: #{data["type"]}"
    end
  end

end