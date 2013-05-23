class EventedCommunication::Server

  attr_reader :host, :port, :connections
  attr_accessor :open_handler, :close_handler

  def initialize host, port
    @host = host
    @port = port
    @connections = []
    @handlers = []
    @inline_handlers = []
  end

  def run
    if EM.reactor_running?
      _run
    else
      EM.run do
        _run
      end
    end
  end

  def register_handler event_type, &block
    @handlers.push [event_type,block]
  end

  def register_inline_handler event_type, &block
    @inline_handlers.push [event_type,block]
  end

  def dispatch_event event, *conn
    conn.each do |c|
      c.socket.send event.serialize
    end
  end

  def dispatch_event_with_payload type, payload, *conn
    event = EC::Event.new type, payload
    dispatch_event event, *conn
  end

  def dispatch_inline_event type, payload
    @inline_handlers.each do |handler|
      handler[1].call payload if handler[0] == type
    end
  end

  protected

  def _run
    EM::WebSocket.run :host => @host, :port => @port do |socket|
      socket.onopen do
        conn = EC::Connection.new self, socket
        @open_handler.call conn if @open_handler
        @connections.push conn
      end
      socket.onclose do
        conn = _connection_for_socket socket
        @close_handler.call conn if @close_handler
        @connections.delete conn
      end
      socket.onmessage do |msg|
        data = JSON.parse msg
        event = EC::Event.from_data data["uid"], data["type"], data["payload"]
        @handlers.each do |handler|
          handler[1].call _connection_for_socket(socket), event if handler[0] == event.type
        end
      end
    end
  end

  def _connection_for_socket socket
    @connections.each do |conn|
      return conn if conn.socket == socket
    end
  end

end