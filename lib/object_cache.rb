module ObjectCache
  def self.append_features(klass)
    # super
    klass.class_eval do
      extend ClassMethods
    end
  end

  module ClassMethods
    def cache
      @cache ||= {}
    end

    def lookup_all ids=nil
      return [] unless ids
      ids.collect {|id| lookup(id) }.compact
    end

    def lookup id
      cache[id]
    end
  end
end

