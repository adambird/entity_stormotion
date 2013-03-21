# Public - pluggable store for the entity_store implementation

class SqliteEntityStore

  def self.store_name=(value)
    @_store_name = value
  end

  def self.store_name
    @_store_name ||= "entity_stormation"
  end

  def db
    @_db ||= FMDatabase.databaseWithPath("#{App.documents_path}/#{SqliteEntityStore.store_name}.db")
  end

  def use_store(&block)
    db.open
    yield db
    db.close
  end

  # Public - adds the entity to the store
  #
  # entity     - An object that behaves an entity, use the EntityStore::Entity mixin
  #
  # Returns String id of the entity
  def add_entity(entity)
    insert_entity = "INSERT INTO entities(type, version) VALUES (\"#{entity.type}\", #{entity.version});"
    new_id = nil
    use_store do |db|
      db.executeUpdate(insert_entity)
      new_id = db.lastInsertRowId
    end
    new_id.to_s
  end

  def save_entity(entity)
    # this will be called if the entity has an id
  end

  # Public - retrieves the entity attributes and returns an empty instance
  # of the appropriate type
  # 
  # id          - String identifying the entity
  # 
  # Returns an instance of the entity
  def get_entity(id)
    get_entity = "SELECT id, type, version FROM entities WHERE id = #{id}"

    attrs = nil

    use_store do |db|
      result = db.executeQuery(get_entity)
      if result.next && result.intForColumn('id')
        attrs = {
          id: id,
          version: result.intForColumn('version'),
          type: result.stringForColumn('type')
        }
      end
    end
    return EntityStore::Config.load_type(attrs[:type]).new(attrs) if attrs
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

  # Public - idempotent init operation for the data store for generating any schema
  #
  def init
    create_entity_table = "CREATE TABLE IF NOT EXISTS entities "\
        "(id INTEGER PRIMARY KEY AUTOINCREMENT, type TEXT NOT NULL, version INTEGER NOT NULL);"

    use_store do |db|
      db.executeUpdate(create_entity_table)
    end
  end

  def clear

  end
end