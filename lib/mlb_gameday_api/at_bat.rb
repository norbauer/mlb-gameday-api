class MLBAPI::AtBat < MLBAPI::Model

  attr_accessor :pitches, :game

  hash_attr_accessor :num, :des, :event

  def player
    game.player(@attributes['player'])
  end

  def update_from_node(abxml)
    if abxml.attribute('num') == self.num
      @attributes.merge!(stringify_xml_node_values(abxml.attributes))
      abxml.xpath("p[position() > #{self.pitches.size}]").each do |pxml|
        pitch = MLBAPI::Pitch.new(pxml.attributes)
        pitch.at_bat = self
        self.pitches << pitch
      end
    else
      self.class.from_node(abxml, self.game)
    end
  end

  def self.from_node(abxml, game)
    ab = new(abxml.attributes)
    ab.game = game
    ab.pitches = []
    abxml.xpath('p').each do |pxml|
      pitch = MLBAPI::Pitch.new(pxml.attributes)
      pitch.at_bat = ab
      ab.pitches << pitch
    end
    ab
  end

  def out?
    scorecard !~ /1B|2B|3B|BB|HBP/
  end

  def rbi?
    des =~ / homers |scores\./
  end

  def scorecard
    # this is broken - trying to split on periods, but not "J.  D.  Drew"
    play, extras = des.split(/(?![A-Z])\./, 2)
    result, players = play.split(/,| to /, 2)
    players = players.split(' to ') if players
    result = case result
    when /^\s*$/
      nil
    when /strikes out swinging/
      'K'
    when /called out on strikes/
      'Kc'
    when /grounds out/
      'G'
    when /grounds into a force out/
      'FC'
    when / singles /
      '1B'
    when / doubles /
      '2B'
    when / triples /
      '3B'
    when / homers /
      'HR'
    when /sacrifice fly/
      'SF'
    when /flies out/
      'F'
    when /pops out/
      'P'
    when /walks/
      'BB'
    when /hit by pitch/
      'HBP'
    when /lines into double play/
      'LIDP'
    when /grounds into double play/
      'GIDP'
    when /double play/
      'HIDP'
    # haven't handled all the possibilities yet, e.g.:
    # "With Nick Johnson batting, Brett Gardner steals (1) home.  Derek Jeter steals (1) 2nd base."
    # "With Curtis Granderson batting, wild pitch by Scott Schoeneweis, Robinson Cano to 3rd.    Jorge Posada to 2nd."
    else
      '??'
    end
    if players
      players.collect! do |player|
        case player
        when /pitcher/
          '1'
        when /catcher/
          '2'
        when /first baseman/
          '3'
        when /second baseman/
          '4'
        when /third baseman/
          '5'
        when /shortstop/
          '6'
        when /left fielder/
          '7'
        when /center fielder/
          '8'
        when /left fielder/
          '9'
        else
          '?'
        end
      end
    end
    if result !~ /\d/
      if players && player.size > 1
        result = "#{players.join('-')} #{result}"
      else
        result = "#{result}#{players.first}"
      end
    end
    result
  end
end
