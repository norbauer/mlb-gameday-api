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

  def scorecard
    case des
    when /^\s*$/
      nil
    when /strikes out swinging/
      'K'
    when /strikes out looking/
      'Kc'
    when /grounds out to first/
      'G3'
    when /singles/
      '1B'
    when /doubles/
      '2B'
    when /triples/
      '3B'
    when /home run/
      'HR'
    when /flys out to left field/
      'F7'
    when /flys out to center field/
      'F8'
    when /flys out to right field/
      'F9'
    when /walks/
      'BB'
    when /hit by pitch/
      'HBP'
    when /double play/
      'HIDP'
    # haven't handled all the possibilities yet
    else
      '??'
    end
  end
end
