class SqliteEntityStore
  
  # Public - adds the entity to the store
  #
  # entity     - An object that behaves an entity, use the EntityStore::Entity mixin
  #
  # Returns String id of the entity
  def add_entity(entity)

  end

  def save_entity(entity)
      # this will be called if the entity has an id
  end

  def get_entity(id)
      # returns the entity as an empty shell of the appropriate type
      # if a snapshot exists then this should be returned
  end

  def get_events(id, since_version=nil)
      # returns all events in time sequence since the version if passed otherwise all
  end

  def snapshot_entity(entity)
      # create a snapshot of the entity that can be retrievd without replaying 
      # the entire event stream
  end

  def remove_entity_snapshot(id)
      # remove the snapshot so next time the entity is retrieved it replays the event stream
      # to rehhydrate the entity
  end
  
end