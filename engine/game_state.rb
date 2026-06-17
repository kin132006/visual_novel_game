
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

  def new_day() #losuje na nowo przedmioty w pokojach

  end
end