class Ogment::Device

  attr_reader :id, :connection
  attr_accessor :active, :strategy, :protection, :language, :search_terms, :game

  def initialize id, conn
    @id = id
    @connection = conn
    @active = false
    @search_terms = []
    @language = "de"
  end

  def search
    @search_terms.last
  end

  def last_search
    @search_terms.size>1 ? @search_terms[-2] : ""
  end

  def player?
    @game ? @game.player == self : false
  end

  def opponent?
    @game ? @game.opponents.include?(self) : false
  end

  def state
    if player?
      return 2
    elsif active
      return 1
    else
      return 0
    end
  end

  # helper

  def log msg
    puts "[D#{@id}] #{msg}"
  end

  def server
    Ogment.data[:server]
  end

end