$LOAD_PATH << '.'
require 'safe_cache'

module JsonFetcher
  include SafeCache
  
  def fetchjson(url, failmsg)
    cached = getcached(url)
    if is_expired?(cached)
      jsn = getjson(url)
      if !jsn.nil?
        jsn["date"] ||= Time.now.to_i
        setcached(url, jsn)
      end
      return jsn
    else
      puts "getting from cache"
      return cached
    end
  end

  def getjson(url, failmsg)
    content = open(url).read
    jsn = JSON.parse(content)
    if jsn.nil?
      raise failuremsg
    end
    return jsn
  end
end
