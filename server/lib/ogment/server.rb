class Ogment::Server

  def run
    EM.run do
      EM::start_server "0.0.0.0", 8000, Ogment::Frontend
      Ogment.data[:server] = EC::Server.new "0.0.0.0", 8080
      Ogment::Backend.new Ogment.data[:server]
      Ogment.data[:server].run
    end
  end

end