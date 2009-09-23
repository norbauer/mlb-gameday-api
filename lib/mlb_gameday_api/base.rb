class MLBAPI::Error < StandardError; end

class MLBAPI::Base

  def self.client
    Thread.current[:MLBAPI_Client] ||= MLBAPI::Client.new
  end

  def self.games(date = Date.today)
    games = []
    game_xml = client.load('miniscoreboard.xml', date)
    game_xml.xpath('/games/game').each do |game|
      games << MLBAPI::Game.new(game.attributes)
    end
    games
  end

end
