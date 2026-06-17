
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