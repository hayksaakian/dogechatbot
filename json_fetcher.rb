module JsonFetcher
  def getjson(url)
    content = open(url).read
    jsn = JSON.parse(content)
    if jsn.nil?
      raise @FETCH_FAIL_MSG ||= "Failed to retrieve json"
    end
    return jsn
  end
end
