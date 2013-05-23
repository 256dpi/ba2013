class EventedCommunication::Event

  attr_accessor :uid, :type, :payload

  def self.from_data uid, type, payload
    event = EC::Event.new type, payload
    event.uid = uid
    event.freeze
  end

  def initialize type, payload
    @uid = UUID.generate
    @type = type
    @payload = payload
  end

  def serialize
    JSON.generate uid: @uid, type: @type, payload: @payload
  end

end