class MLBAPI::FetchError < MLBAPI::Error; end

class MLBAPI::Client

  def initialize
    @cache = MLBAPI::Cache.new
    @curl = Curl::Easy.new
  end

  def load(path, date = Date.today)
    url = construct_url(path, date)
    @cache.get(url) or fetch(url)
  end

private

  def construct_url(path, date)
    "http://gdx.mlb.com/components/game/mlb/year_%d/month_%02d/day_%02d/%s" % [date.year, date.month, date.day, path]
  end

  def fetch(url, retries = 3)
    @curl.url = url
    @curl.headers['If-Modified-Since'] = @cache.stamp(url)
    @curl.perform
    case @curl.response_code
    when 304
      @cache.keep(key, local_expiration(@curl))
      @cache.content(key)
    when 200
      @cache.set(url, parse_body(@curl), local_expiration(@curl))
    else
      if retries <= 0
        raise MLBAPI::FetchError, "HTTP #{@curl.response_code} - GET #{url}"
      else
        fetch(url, retries - 1)
      end
    end
  end

  def parse_body(doc)
    Nokogiri::XML(doc.body_str)
  end

  def local_expiration(doc)
    expires = header(doc, 'Expires') and date = header(doc, 'Date') and Time.parse(expires) + (Time.now - Time.parse(date))
  end

  def header(doc, key)
    match = doc.header_str.match(/[\r\n\A]#{key}: ([^\r\n]*)/) and match[1]
  end

end
