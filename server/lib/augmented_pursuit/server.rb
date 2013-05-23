class AugmentedPursuit::Server

  def run
    EM.run do
      EM::start_server "0.0.0.0", 8000, AugmentedPursuit::Frontend
      AugmentedPursuit.data[:server] = EC::Server.new "0.0.0.0", 8080
      AugmentedPursuit::Backend.new AugmentedPursuit.data[:server]
      AugmentedPursuit.data[:server].run
    end
  end

end