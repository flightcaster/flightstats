class Hash
  
  def underscore_keys
    inject({}) do |options, (key, value)|
      options[key.to_s.underscore] = value
      options
    end
  end
  
  def underscore_keys!
    keys.each do |key|
      self[key.to_s.underscore] = delete(key)
    end
    self
  end
  
end