
class Dialogue
  attr_accessor :id, :char, :dial, :reqs, :opts
  def initialize(id, char, dial, reqs, opts)
    @id = id
    @char = char
    @dial = dial #kwestia dialogowa
    @reqs = reqs #lista wymagań
    @opts = opts #lista opcji
  end

  def is_possible?(game_state)
    @reqs.each do |req|
      if !req.fullfilled?(game_state)
        return false
      end
    end
    return true   
  end

  def show()
    print @dial
  end
end