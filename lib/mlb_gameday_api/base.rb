class MLBAPI::Error < StandardError; end

class MLBAPI::Base

  def self.client
    Thread.current[:MLBAPI_Client] ||= MLBAPI::Client.new
  end

  def self.find_all_games(date = Date.today)
    games = []
    game_xml = client.load('miniscoreboard.xml', date)
    game_xml.xpath('/games/game').each do |game|
      games << MLBAPI::Game.new(game.attributes)
    end
    games
  end

  # all games because of double-headers and such. team should be the 2 or 3 letter
  # abbreviation, all caps, like BOS, NYY, NYM, LAA, LAD, SD, SF, KC, TB, etc.
  def self.find_all_games_by_team(team, date = Date.today)
    games = []
    game_xml = client.load('miniscoreboard.xml', date)
    game_xml.xpath("/games/game[@away_name_abbrev='#{team}'] | /games/game[@home_name_abbrev='#{team}']").each do |game|
      games << MLBAPI::Game.new(game.attributes)
    end
    games
  end

private

  def client
    self.class.client
  end

end

