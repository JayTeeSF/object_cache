require 'yaml/store'

module ObjectCache
  class FileStore
    DEFAULT_FILE = "/tmp/file_store.yml"

    def self.registration_key
      ObjectCache.key_for(self)
    end

    def self.register(_as=nil, *args)
      _as ||= registration_key
      #FIXME: make this work w/ a
      #lambda or method,
      #not a specific instance
      [new(*args), _as]
    end

    def initialize(options=nil)
      options ||= {}
      @file = options[:file] || DEFAULT_FILE
      storage_class = options[:storage_class] || YAML::Store
      @store = storage_class.new @file
      @transactor = options[:transactor] || @store
    end

    def fetch(key, default=unknown_key)
      @transactor.transaction { raw_fetch(key, default) }
    end

    def store key, value
      @transactor.transaction { @store[key] = value }
    end

    def values
      @transactor.transaction { roots.map{|key| raw_fetch(key, unknown_key)} }
    end

    private
    def unknown_key; nil; end
    def roots; @store.roots; end
    def raw_fetch(key, default=unknown_key); @store.fetch(key, default); end
  end
end
