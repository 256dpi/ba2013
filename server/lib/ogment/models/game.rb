class Ogment::Game

  attr_reader :id, :player, :opponents, :turn

  def initialize player, opponents
    @id = Ogment.data[:game_counter]+=1
    @player = player
    @opponents = opponents
    @turn_counter = 0
  end

  def all_devices
    return (@opponents+[@player]).uniq
  end

  def demo?
    @opponents.size == 1 && @opponents[0] == @player
  end

  def start
    log "new game started"
    all_devices.each{ |d| d.game = self }
    if demo?
      server.dispatch_event_with_payload "game_started", "demo", @player.connection
    else
      server.dispatch_event_with_payload "game_started", "player", @player.connection
      server.dispatch_event_with_payload "game_started", "opponent", *@opponents.map{ |d| d.connection }
    end
    Ogment.data[:games].push self
  end

  def new_turn search
    log "new turn started"
    @turn = Ogment::Turn.new @turn_counter+=1, self, search
    if demo?
      server.dispatch_event_with_payload "select_attack", "", @player.connection
    else
      server.dispatch_event_with_payload "select_attack", "", *@opponents.map{ |d| d.connection }
    end
  end

  def cancel reason
    server.dispatch_event_with_payload "game_canceled", reason, *all_devices.map{ |d| d.connection }
    self.end
  end

  def end
    log "game will end"
    server.dispatch_event_with_payload "game_ended", "", *all_devices.map{ |d| d.connection }
    all_devices.each{ |d| d.game = nil }
    Ogment.data[:games].delete self
  end

  # helper

  def log msg
    puts "[G#{@id}] #{msg}"
  end

  def server
    Ogment.data[:server]
  end

end