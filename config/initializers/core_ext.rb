class Hash
  def deep_clone
    self.map { |k, v| {k => ((!(v.target!.is_a?(String) rescue nil) && v.respond_to?(:deep_clone)) ? v.deep_clone : v)} }.inject(&:merge)
  end
end

class Array
  def deep_clone
    self.map { |v| v.respond_to?(:deep_clone) ? v.deep_clone : v }
  end
end


def escape_hash(hash)
  (hash||{}).inject({}) do |h, (k, v)|
    if v.kind_of? String
      h[k] = URI.escape(v)
    else
      h[k] = escape_hash(v)
    end
    h
  end
end

