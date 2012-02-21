module ObjectCache
  def self.append_features(klass)
    klass.class_eval do
      extend ClassMethods
    end
  end

  module ClassMethods
    def cache
      @cache ||= {}
    end

    def lookup_all(ids=nil)
      if ids
        lookup(ids)
      else
        cache.values
      end
    end

    def lookup(id_or_ids)
      if id_or_ids.respond_to?(:collect)
        id_or_ids.collect {|id| lookup(id) }.compact
      else
        cache[id_or_ids]
      end
    end
  end
end
