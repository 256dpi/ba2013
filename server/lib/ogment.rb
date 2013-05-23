require "em-http-server"
require "haml"
require "httparty"
require "cgi"
require "json"

module Ogment

  autoload :Server, "ogment/server"
  autoload :Frontend, "ogment/frontend"
  autoload :Backend, "ogment/backend"
  autoload :Internet, "ogment/internet.rb"

  autoload :Device, "ogment/models/device.rb"
  autoload :Game, "ogment/models/game.rb"
  autoload :Turn, "ogment/models/turn.rb"

  def self.data
    @@data ||= { :devices => [], :games => [], :game_counter => 0 }
  end

end