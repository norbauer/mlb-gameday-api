class MLBAPI::Game < MLBAPI::Model

  attr_accessor :at_bat, :offense, :defense,
                :home_lineup, :away_lineup,
                :batter, :pitcher, :deck, :hole,
                :weather

  def initialize(*)
    super
    @innings = {}
  end

  # list of attributes and sample values

  # [["ampm", "PM"],
  #  ["away_code", "nya"],       # not sure what this is for
  #  ["away_division", "E"],     # East, Central, West
  #  ["away_file_code", "nyy"],
  #  ["away_league_id", "103"],
  #  ["away_loss", "56"],
  #  ["away_name_abbrev", "NYY"],
  #  ["away_preview_link", "javascript:void(...)"],
  #  ["away_sport_code", "mlb"],
  #  ["away_team_city", "NY Yankees"],
  #  ["away_team_errors", "0"],
  #  ["away_team_hits", "7"],
  #  ["away_team_id", "147"],
  #  ["away_team_name", "Yankees"],
  #  ["away_team_runs", "3"],
  #  ["away_win", "97"],
  #  ["day", "WED"],
  #  ["game_pk", "246466"],
  #  ["game_type", "R"],        # Regular, Post-season... Spring Training?
  #  ["gameday_link", "2009_09_23_nyamlb_anamlb_1"],
  #  ["gameday_sw", "E"],
  #  ["home_code", "ana"],
  #  ["home_division", "W"],
  #  ["home_file_code", "ana"],
  #  ["home_league_id", "103"],
  #  ["home_loss", "62"],
  #  ["home_name_abbrev", "LAA"],
  #  ["home_preview_link", "javascript:void(...)"],
  #  ["home_sport_code", "mlb"],
  #  ["home_team_city", "LA Angels"],
  #  ["home_team_errors", "1"],
  #  ["home_team_hits", "10"],
  #  ["home_team_id", "108"],
  #  ["home_team_name", "Angels"],
  #  ["home_team_runs", "2"],
  #  ["home_win", "90"],
  #  ["id", "2009/09/23/nyamlb-anamlb-1"],
  #  ["ind", "F"],              # Final, In progress, Postponed?, Delay?
  #  ["inning", "9"],
  #  ["league", "AA"],          # AA / NN for american and national, interleague may be AN or NA
  #  ["outs", "3"],
  #  ["scheduled_innings", "9"],
  #  ["status", "Final"],
  #  ["time", "3:35"],
  #  ["time_zone", "ET"],
  #  ["top_inning", "N"],       # 'N' for bottom of the inning, 'T' for top of the inning
  #  ["tv_station", "FS-W, MLBN"],
  #  ["venue", "Angel Stadium of Anaheim"],
  #  ["venue_id", "1"],
  #  ["venue_w_chan_loc", "USCA0027"],
  #  ["wrapup_link", "javascript:void(...)"]]

  # A few more I've found, but not always present:
  #  ["away_games_back", "6.5"],
  #  ["away_games_back_wildcard", "-"],
  #  ["home_games_back", "17.5"],
  #  ["home_games_back_wildcard", "26.5"],

  def players
    @players ||= MLBAPI::Player.find_all_by_game(self, date)
  end

  def player(id)
    players.find { |p| p.id == id.to_s }
  end

  # 'home' or 'away'
  def team(t)
    players.select { |p| p.team == t.to_s }
  end

  def inning(inning)
    # re-fetch inning
    if !['Final', 'Game Over'].include?(self.status) && @innings[inning] && @inning[inning].next == 'N'
      @inning[inning] = nil
    end
    @innings[inning] ||= Inning.find_by_game_and_number(self, inning)
  end

  # updates the current state of the game using the plays data
  def update
    pxml = client.load("gid_#{game.gameday_link}/players.xml", date)
    game = pxml.xpath('/game')
    @attributes.merge(stringify_xml_node_values(remap_hash(game.attributes, { 
      'status' => 'status',
      'inning' => 'inning',
      'top_inning' => 'top_inning',
      'b' => 'balls',
      's' => 'strikes',
      'o' => 'outs'
    })))
    score = game.xpath('score')
    @attribute.merge(stringify_xml_node_values(remap_hash(score.attributes, {
      'ar' => 'away_team_runs',
      'ah' => 'away_team_hits',
      'ae' => 'away_team_errors',
      'hr' => 'home_team_runs',
      'hh' => 'home_team_hits',
      'he' => 'home_team_errors'
    })))
    self.at_bat = MLBAPI::AtBat.from_node(game.xpath('atbat'), self)
  end

  def date
    @date ||= Date.new(*self.id.split('/')[0..2].collect(&:to_i))
  end

end
