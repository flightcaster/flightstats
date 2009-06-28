class String
  def underscore
    string = self.sub('::', '/')
    string.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
    string.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    string.sub!("-", "_")
    string.downcase
  end
end