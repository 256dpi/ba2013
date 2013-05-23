class AugmentedPursuit::Backend

  def initialize server
    @server = server

    @server.open_handler = lambda do |conn|
      log "new connection attempt"
    end

    @server.close_handler = lambda do |conn|
      device = device_by_connection conn
      device.log "connection lost"
      AugmentedPursuit.data[:devices].delete device
    end

    @server.register_handler "client_identification" do |conn,event|
      if (old_device = device_by_id event.payload["device_id"])
        AugmentedPursuit.data[:devices].delete old_device
      end
      device = AugmentedPursuit::Device.new event.payload["device_id"], conn
      device.log "identified"
      AugmentedPursuit.data[:devices].push device
      @server.dispatch_event_with_payload "client_identified", "", conn
    end

    @server.register_handler "activness_changed" do |conn,event|
      origin = device_by_connection(conn)
      origin.active = event.payload
      origin.log "changed activness to #{origin.active.to_s}"
      send_device_matrix
    end

    @server.register_handler "request_new_game" do |conn,event|
      origin = device_by_connection conn
      origin.log "requested new game"
      possible_opponents = AugmentedPursuit.data[:devices].select do |d|
        d.id != origin.id && d.active && !d.game
      end
      if origin.active && possible_opponents.size > 0
        origin.log "start new game with opponents"
        game = AugmentedPursuit::Game.new origin, possible_opponents
      else
        origin.log "start ego game"
        game = AugmentedPursuit::Game.new origin, [origin]
      end
      game.start
      send_device_matrix
    end

    @server.register_handler "end_game" do |conn,event|
      origin = device_by_connection conn
      origin.log "will finish game"
      origin.game.end if origin.game
      send_device_matrix
    end

    @server.register_handler "strategy_changed" do |conn,event|
      origin = device_by_connection(conn)
      origin.strategy = event.payload
      origin.log "changed strategy to #{origin.strategy}"
    end

    @server.register_handler "protection_changed" do |conn,event|
      origin = device_by_connection(conn)
      origin.protection = event.payload
      origin.log "changed protection to #{origin.protection}"
    end

    @server.register_handler "new_search" do |conn,event|
      origin = device_by_connection conn
      origin.log "requested new search"
      if origin.player?
        origin.game.new_turn event.payload
        origin.search_terms.push event.payload
        origin.search_terms = origin.search_terms.take 5
      end
    end

    @server.register_handler "attack_selected" do |conn,event|
      origin = device_by_connection conn
      origin.log "selected attack #{event.payload}"
      if origin.opponent?
        origin.game.turn.select_attack origin, event.payload
        if origin.game.turn.attack_selection_complete?
          origin.game.turn.pick_opponent
          if origin.game.turn.denial_of_service
            log "denial of service detected"
            origin.game.cancel "denial_of_service"
            send_device_matrix
          else
            @server.dispatch_inline_event "attack_selection_complete", origin.game.player
          end
        end
      end
    end   

    @server.register_inline_handler "attack_selection_complete" do |player|
      log "attack selection complete"
      if player.player? || player.opponent?
        query = get_search_query player
        results = AugmentedPursuit::Internet.search_for_string query, player.language
        results = manipulate_search_results player, results
        if player.game.turn.selected_attack == "phishing"
          player.game.turn.results_cache = results
          @server.dispatch_event_with_payload "create_fake_result", "", player.game.turn.opponent.connection
        else
          @server.dispatch_event_with_payload "display_results", results, player.connection
        end
      end
    end

    @server.register_handler "fake_result_created" do |conn,event|
      origin = device_by_connection conn
      origin.log "sent fake result"
      if origin.opponent?
        results = add_fake_to_results event.payload, origin.game.turn.results_cache
        @server.dispatch_event_with_payload "display_results", results, origin.game.player.connection        
      end
    end

    @server.register_handler "fake_result_selected" do |conn,event|
      origin = device_by_connection conn
      log "fake result selected"
      origin.game.cancel "fake_result"
      send_device_matrix
    end

    @server.register_handler "request_page" do |conn,event|
      origin = device_by_connection conn
      origin.log "requested page #{event.payload}"
      if origin.player?
        page = AugmentedPursuit::Internet.page_by_url event.payload, origin.language
        if origin.game.turn.selected_attack == "man_in_the_middle"
          @server.dispatch_event_with_payload "manipulate_page", { page: page, url: event.payload }, origin.game.turn.opponent.connection
        else
          @server.dispatch_event_with_payload "display_page", { page: page, url: event.payload }, origin.connection
        end
      end
    end

    @server.register_handler "page_manipulated" do |conn,event|
      origin = device_by_connection conn
      origin.log "sent manipulated page"
      if origin.opponent?
        @server.dispatch_event_with_payload "display_page", { page: event.payload["page"], url: event.payload["url"] }, origin.game.player.connection
      end
    end

  end

  # event helpers

  def send_device_matrix
    null_matrix = Hash.new
    AugmentedPursuit.data[:devices].each do |device|
      null_matrix[device.id.to_i] = device.state
    end
    AugmentedPursuit.data[:devices].each do |device|
      indexes = [1,2,3,4]
      (device.id.to_i-1).times do
        indexes.push indexes.shift
      end
      matrix = Hash.new
      matrix[:current] = null_matrix[indexes[0]] || 0
      matrix[:left] = null_matrix[indexes[1]] || 0
      matrix[:facing] = null_matrix[indexes[2]] || 0
      matrix[:right] = null_matrix[indexes[3]] || 0
      @server.dispatch_event_with_payload "active_device_matrix_changed", matrix, device.connection if device.active
    end
  end

  # game helpers

  def get_search_query player
    query = player.game.turn.search
    if player.game.turn.include_strategy?("personalized_search") && player.protection != "private_browsing"
      log "applied strategy personalized_search"
      query += " #{player.last_search}"
    end
    return query
  end

  def manipulate_search_results player, results
    log "current player protection: #{player.protection}"
    if player.game.turn.include_strategy?("advertisement") && player.protection != "ad_blocker"
      log "applied strategy advertisement"
      50.times do
        results.insert Random.rand(0..results.size-1), { title: "ADVERTISEMENT", :type => :ad }
      end
    end
    if player.game.turn.include_strategy?("censorship") && player.protection != "vpn_server"
      log "applied strategy censorship"
      30.times do
        item = results[Random.rand(0..results.size-1)]
        item[:type] = :censored
      end
    end
    return results
  end

  def add_fake_to_results fake, results
    results.insert 0, { title: fake, :type => :fake }
    return results
  end

  # basic helpers

  def device_by_connection conn
    AugmentedPursuit.data[:devices].each do |device|
      return device if device.connection == conn
    end
  end

  def device_by_id id
    AugmentedPursuit.data[:devices].each do |device|
      return device if device.id == id
    end
  end

  def log msg
    puts "[XX] #{msg}"
  end

end