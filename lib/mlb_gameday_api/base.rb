class MLBAPI::Error < StandardError; end

class MLBAPI::Base

  def initialize
    @client = MLBAPI::Client.new
  end

end
