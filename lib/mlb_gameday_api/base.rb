require 'time'

module MLBApi; class Base
  def initialize
    @cache = MLBApi::Cache.new
    @curl = Curl::Easy.new
  end

  def load(path, date = Date.today)
    url = construct_url(path, date)
    @cache.get(url) or fetch(url)
  end

private

  def construct_url(path, date)
    "http://gdx.mlb.com/components/game/mlb/year_#{date.year}/month_#{'%02d' % date.month}/day_#{'%02d' % date.day}/#{path}"
  end

  def fetch(url)
    @curl.url = url
    @curl.headers['If-Modified-Since'] = @cache.stamp(url)
    @curl.perform
    if @curl.response_code == 304
      @cache.keep(key, local_expiration(@curl))
      @cache.content(key)
    else
      @cache.set(url, parse_body(@curl), local_expiration(@curl))
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
