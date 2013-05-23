require "em-http-server"
require "haml"
require "httparty"
require "cgi"
require "json"

module AugmentedPursuit

  autoload :Server, "augmented_pursuit/server"
  autoload :Frontend, "augmented_pursuit/frontend"
  autoload :Backend, "augmented_pursuit/backend"
  autoload :Internet, "augmented_pursuit/internet.rb"

  autoload :Device, "augmented_pursuit/models/device.rb"
  autoload :Game, "augmented_pursuit/models/game.rb"
  autoload :Turn, "augmented_pursuit/models/turn.rb"

  def self.data
    @@data ||= { :devices => [], :games => [], :game_counter => 0 }
  end

end