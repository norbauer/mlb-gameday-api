class MLBAPI::Player < MLBAPI::Model

  # hitter:
  #  id="425903" first="Kevin" last="Youkilis" num="20" boxname="Youkilis" rl="R" position="1B" status="A" bat_order="4" game_position="3B" avg=".308" hr="25" rbi="86"
  # pitcher:
  #  id="449097" first="Jonathan" last="Papelbon" num="58" boxname="Papelbon" rl="R" position="P" status="A" avg=".000" hr="0" rbi="0" wins="1" losses="1" era="1.97"

  hash_attr_accessor :id, :first, :last, :num, :boxname, :rl, :position, :status, :bat_order,
                     :game_position, :avg, :hr, :rbi, :wins, :losses, :era

  def pitcher?
    self.position == 'P'
  end

  def self.find_all_by_game(game, date)
    players = []
    client.load("gid_#{game.gameday_link}/players.xml", date).xpath('/game/team').each do |team|
      home_or_away = team.attribute('type').to_s
      team.xpath('player').each do |player|
        players << new(player.attributes.merge('game' => game, 'team' => home_or_away))
      end
    end
    players
  end

end
