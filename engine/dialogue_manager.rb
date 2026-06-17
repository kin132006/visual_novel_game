
class DialogueManager
  #przechodzi przez graf dialogu, sprawdza wymagania i wywołuje efekty
  def initialize(game_state, dial)
    @game_state = game_state
    @dial = dial
  end
  
  def talk()
    akt = @dial
    while akt != nil
      akt.show()
      opt = choose_opt(akt)
      opt.apply_eff(@game_state)
      akt = opt.next_dial
    end
  end

  def choose_opt(dial)
    poss_opts = []
    licz = 1
    dial.opts.each do |opt|
      print "#{licz}. "
      licz += 1
      opt.show()
      if opt.is_possible 
        poss_opts << opt
      else
        poss_opts << nil
        print " X"
        puts ""
      end
    end
    puts "Choose an option"
    choice = gets.chomp.to_i
    while choice>poss_opts.size or choice<=0 or poss_opts[choice]==nil
      print "Invalid option, choose again: "
      choice = gets.chomp.to_i
    end
    poss_opts[choice]
  end

end