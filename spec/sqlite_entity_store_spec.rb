# Integration tests for the local store
include EntityStore

class DummyEntity
  include Entity

  attr_accessor :name

  def set_name(name)
    record_event DummyEntityNameSet.new(name: name)
  end
end

class DummyEntityNameSet
  include Event

  attr_accessor :name

  def apply(entity)
    entity.name = name
  end
end

describe SqliteEntityStore do
  let(:store) { SqliteEntityStore.new }
  let(:name) { random_string }

  describe "#add_entity" do
    before(:each) do
      @entity = DummyEntity.new
      @entity.set_name name
    end

    subject { store.add_entity @entity }

    it "should return an id" do
      subject.should_not be_nil
    end
    it "should be possible to retrieve the entity by the id" do
      
    end
  end
end