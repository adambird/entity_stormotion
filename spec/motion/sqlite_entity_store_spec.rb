# Integration tests for the local store

class DummyEntity
  include EntityStore::Entity

  attr_accessor :name

  def set_name(at, name)
    record_event DummyEntityNameSet.new(at: at, name: name)
  end

end

class DummyEntityNameSet
  include EntityStore::Event

  attr_accessor :name
  time_attribute :at

  def apply(entity)
    entity.name = name
  end
end

describe "SqliteEntityStore" do
  before do
    @store = EntityStormotion::SqliteEntityStore.new
    @store.open
    @store.clear
    @name = "asjdlakjdlkajd"
    @at = Time.now
  end

  describe "#add_entity" do
    before do
      @entity = DummyEntity.new
      @entity.set_name @at, @name
      @id = @store.add_entity @entity
    end

    it "should allow retrieval of the entity shell for the id" do
      @store.get_entity(@id).class.name.should == DummyEntity.name
    end
  end

  describe "#add_event" do
    before do
      @entity_id = "2234"
      @event = DummyEntityNameSet.new(at: Time.now, name: "skdfhskjf", entity_id: @entity_id, entity_version: 2)
      @store.add_event @event
    end

    it "should allow retrieval of the events for that entity" do
      @store.get_events(@entity_id).first.name.should == @event.name
    end
    it "should be of the correct type" do
      @store.get_events(@entity_id).first.class.name.should == DummyEntityNameSet.name
    end
  end

  describe "#snapshot_entity" do
    before do
      @entity = DummyEntity.new
      @entity.set_name @at, @name
      @entity.id = @store.add_entity @entity
      @store.snapshot_entity @entity
    end

    it "should populate the entity with the snapshot" do
      @store.get_entity(@entity.id).name.should == @name
    end
  end

  describe "Integration with EntityStore" do
    before do
      EntityStore::Config.setup do |config|
        config.store = @store
      end
      @entity = DummyEntity.new
      @entity_store = EntityStore::Store.new
    end

    describe "#save" do
      before do
        @entity.set_name(@at = Time.now, @name = "sdhfsfhof")
        @entity = @entity_store.save(@entity)
      end

      it "retrieved has name" do
        @entity_store.get(@entity.id).name.should == @name
      end
    end
  end
end
