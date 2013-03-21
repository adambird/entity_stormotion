# Integration tests for the local store

class DummyEntity
  include EntityStore::Entity

  attr_accessor :name

  def set_name(name)
    record_event DummyEntityNameSet.new(name: name)
  end
end

class DummyEntityNameSet
  include EntityStore::Event

  attr_accessor :name

  def apply(entity)
    entity.name = name
  end
end

describe "SqliteEntityStore" do
  before do
    @store = SqliteEntityStore.new
    @name = "asjdlakjdlkajd"
  end

  describe "#add_entity" do
    before do
      @entity = DummyEntity.new
      @entity.set_name @name
      @id = @store.add_entity @entity
    end

    it "should return the entity shell for the id" do
      @store.get_entity(@id).class.name.should == DummyEntity.name
    end
  end
end
