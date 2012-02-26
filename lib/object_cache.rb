require "#{File.dirname(__FILE__)}/string_overrides.rb"
module ObjectCache
  extend self

  DEFAULT_CACHE_LOCATION = :memory
  DEFAULT_CACHE_OBJECT = {}

  def self.append_features(base)
    base.class_eval do
      include InstanceMethods
      extend ClassMethods
    end
  end

  def registration_for(klass_or_key)
    key = key_for(klass_or_key)
    ObjectCache.cache_object.fetch(key, nil)
  end

  def registered?(klass_or_key)
    !! registration_for(klass_or_key)
  end

  def key_for(klass_or_key)
    klass_or_key.to_s.underscore.split('/').last.to_sym
  end

  def registered
    ObjectCache.cache_object.keys
  end

  # TODO:
  # add support for other APIs
  # e.g. active_record, redis, mongo, etc
  def register(_cache_location_class, as=nil)
    _cache_location, as = _cache_location_class.register(as)
    ObjectCache.cache_object[as] = _cache_location
  end

  def flush
    @cache_object = nil
  end

  def cache_object
    @cache_object ||= {
      ObjectCache::DEFAULT_CACHE_LOCATION => ObjectCache::DEFAULT_CACHE_OBJECT
    }
  end

  module InstanceMethods
    def save(_id=id, _obj=self)
      self.class.cache.store(_id, _obj)
    end
  end

  module ClassMethods
    # for example, for fast in-memory caching w/ subsequent backup to db
    #   cache :in => [:memory, :db]
    def cache(options={})
      @cache ||=
        begin
          self.cache_location = options[:in] || ObjectCache::DEFAULT_CACHE_LOCATION
          self._cache ||= ObjectCache.cache_object
          self._cache.fetch(self.cache_location)
        end
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
        id_or_ids.collect {|id| lookup(id) }
      else
        cache.fetch(id_or_ids, nil)
      end
    end

    attr_accessor :cache_location
    attr_accessor :_cache
  end

end
Dir.glob("#{File.dirname(__FILE__) + '/object_cache'}/*.rb").each {|f| require(f) }
