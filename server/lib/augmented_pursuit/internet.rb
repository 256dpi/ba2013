# encoding: utf-8

class AugmentedPursuit::Internet

  BING_BASE = "https://api.datamarket.azure.com/Bing/SearchWeb/v1"
  BING_API_KEY = "UG15xAbv2dD6xGaeoLKWVtzMI2YrMPO9oy7wa9rXYzk="

  def self.search_for_string string, lang
    ret = nil
    begin
      auth = {:username => BING_API_KEY, :password => BING_API_KEY }
      query = CGI::escape(string)
      response = HTTParty.get "#{BING_BASE}/Web?$format=json&Query='site:#{lang}.wikipedia.org+#{query}'", :basic_auth => auth
      data = JSON.parse(response.body)["d"]["results"]
      ret = data.map do |entry|
        { :title => entry["Title"].gsub(/\s\p{Punct}\sW.*$/,""), :url => entry["Url"], :type => :result }
      end
    rescue
      ret = []
    end
    return ret
  end

  def self.page_by_url url, lang
    text = nil
    begin
      url = "" if !url
      page = url.gsub(/http:\/\/..\.wikipedia\.org\/wiki\//,"")
      req = "http://#{lang}.wikipedia.org/w/api.php?action=parse&page=#{page}&format=json&prop=text&redirects"
      response = HTTParty.get req
      text = JSON.parse(response.body)["parse"]["text"]["*"]
    rescue
      text = "ERROR LOADING PAGE"
    end
    return text
  end

end
