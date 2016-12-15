module ServiceFlow
  class ActionRef
    @@actions = {}

    def self.add(key, action)
      @@actions[key] = action
    end

    def self.new(key_or_hash)

      key =  key_or_hash.is_a?(Hash) ? key_or_hash['key'] : key_or_hash
      unless @@actions.has_key? key
        raise "No action of key `#{key}`"
      end
      action = @@actions[key]
    end
  end
end
