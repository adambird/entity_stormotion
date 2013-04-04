module EntityStormotion
  module Config
    def self.setup
      EntityStore::Config.setup do |config|
        config.store = SqliteEntityStore.new
      end
    end
  end
end