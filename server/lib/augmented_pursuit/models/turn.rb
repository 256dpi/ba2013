class AugmentedPursuit::Turn

  attr_reader :id, :game, :search, :attacks, :opponent, :denial_of_service
  attr_accessor :results_cache

  def initialize id, game, search
    @id = id
    @game = game
    @search = search
    @attacks = {}
    @denial_of_service = false
  end

  def select_attack opponent, attack
    @attacks[opponent] = attack if @game.opponents.include? opponent
  end

  def attack_selection_complete?
    @game.opponents.size == @attacks.size
  end

  def pick_opponent
    denial_of_service = false
    @attacks.each do |op,at|
      if at == "denial_of_service"
        denial_of_service = true
        @attacks.delete op
      end
    end
    if @attacks.size == 0 && denial_of_service
      @denial_of_service = true
    else
      if @game.demo?
        @opponent = @game.player
      else
        ops = @attacks.keys.shuffle
        while ops.size > 0
          op = ops.shift
          @opponent = op if @attacks[op] != "none"
        end
      end
    end
  end

  def selected_strategies
    @game.opponents.map{ |o| o.strategy }.uniq - ["none"]
  end

  def include_strategy? strategy
    selected_strategies.include? strategy
  end

  def selected_attack
    @opponent ? @attacks[@opponent] : "none"
  end

  # helper

  def log msg
    puts "[T#{@id}] #{msg}"
  end

  def server
    AugmentedPursuit.data[:server]
  end

end