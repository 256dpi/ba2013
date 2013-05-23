class Ogment::Frontend < EM::HttpServer::Server

  def process_http_request
    begin
      engine = Haml::Engine.new File.read File.expand_path "../views/index.html.haml", __FILE__
      response = EM::DelegatedHttpResponse.new self
      response.status = 200
      response.content_type "text/html"
      response.content = engine.render
      response.send_response
    rescue Exception => e
      http_request_errback e
    end
  end

  def http_request_errback e
    response = EM::DelegatedHttpResponse.new self
    response.status = 501
    response.content_type "text/html"
    response.content = "Error! "+e.to_s
    response.send_response
  end

end