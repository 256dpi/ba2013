God.watch do |w|
  w.name = "augmented_pursuit"
  w.start = File.dirname(__FILE__)+"/bin/augmented_pursuit"
  w.keepalive
end