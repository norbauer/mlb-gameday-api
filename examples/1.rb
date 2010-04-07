$: << File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'mlb_gameday_api'

game = MLBAPI::Base.find_all_games_by_team('BOS').first

10.times do |x|
  game.update
  puts game.at_bat.des
  sleep 10
end
