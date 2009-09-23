class MLBAPI::Cache

  def initialize
    @cache = Hash.new
  end

  def get(key)
    @cache[key] && @cache[key][:expires_at] > Time.now && @cache[key][:content]
  end

  def content(key)
    @cache[key] && @cache[key][:content]
  end

  def stamp(key)
    @cache[key] && @cache[key][:cached_at]
  end

  def keep(key, new_expiration)
    @cache[key] && @cache[key].merge(:cached_at => Time.now, :expires_at => new_expiration)
  end

  def set(key, content, expires)
    @cache[key] = { :expires_at => expires, :content => content, :cached_at => Time.now }
    content
  end

end
