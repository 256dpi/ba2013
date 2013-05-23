require "eventmachine"
require "em-websocket"
require "uuid"

module EventedCommunication

  autoload :Server, "evented_communication/server"
  autoload :Connection, "evented_communication/connection"
  autoload :Event, "evented_communication/event"

end

EC = EventedCommunication