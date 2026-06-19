
require Set
require_relative 'time'

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

  def set_default() #losuje na nowo przedmioty w pokojach
    @Assets.characters.keys.each do |char|
      @relations[char] = 0
    end
    @Assets.rooms.keys.each do |room|
      @item_loc[room] = []
      @char_loc[room] = []
    end
    @room = Assets.rooms.keys.first
    @inventory = []
    @flags = Set.new
  end

  def set_positions()

    all_rooms = @Assets.rooms.keys

    return if all_rooms.empty?

    all_rooms.each do |room|
      @item_loc[room] = []
      @char_loc[room] = []
    end
    
    @Assets.characters.keys.each do |char|
      @random_room = all_rooms.sample
      @char_loc[random_room] << char
    end

    @Assets.items.keys.each do |item|
      unless @inventory.include?(item_id)
        @random_room = all_rooms.sample
        @item_loc[random_room] << item
      end
    end
    puts "Positions were reset"
  end

  def new_day
    puts "NEW DAY"
    set_positions
  end
end