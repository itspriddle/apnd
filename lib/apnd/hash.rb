class Hash
  def deep_symbolize
    inject({}) do |hash, (key, val)|
      val = val.deep_symbolize if val.is_a?(Hash)
      hash[key.to_sym] = val
      hash
    end
  end unless respond_to?(:deep_symbolize)
end
