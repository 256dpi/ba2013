class EventedCommunication::Connection

  attr_reader :server, :socket

  def initialize server, socket
    @server = server
    @socket = socket
  end

end