class MLBAPI::AtBat < MLBAPI::Model

  attr_accessor :pitches

  def player
    game.player(@attributes['player'])
  end

  def self.from_node(abxml, game)
    ab = new(abxml.attributes.merge('game' => game))
    ab.pitches = []
    abxml.xpath('p').each do |pxml|
      ab.pitches << MLBAPI::Pitch.new(pxml.attributes)
    end
  end

end
