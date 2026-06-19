
class Option
  attr_accessor :id, :dial, :reqs, :effs, :next_dial
  def initialize(id, dial, reqs, effs, next_dial)
    @id = id
    @dial = dial
    @reqs = reqs
    @effs = effs
    @next_dial = next_dial
  end

  def is_possible?(game_state)
    @reqs.each do |req|
      if !req.fullfilled?(game_state)
        return false
      end
    end
    return true   
  end

  def apply_eff(game_state)
    @effs.each do |eff|
      eff.apply(game_state)
    end
  end

  def show()
    print dial
  end
end