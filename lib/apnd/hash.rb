class Hash
  # Public: Returns a copy of Hash with all keys set as symbols. If values are
  # Hashes, they are traversed and converted as well.
  def deep_symbolize
    inject({}) do |hash, (key, val)|
      val = val.deep_symbolize if val.respond_to?(:deep_symbolize)
      hash[key.to_sym] = val
      hash
    end
  end unless respond_to?(:deep_symbolize)
end
