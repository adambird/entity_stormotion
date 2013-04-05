# Public - pluggable store for the entity_store implementation

module EntityStormotion
  class SqliteEntityStore

    # Public - setter for the name of the filename to use for the store
    # 
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
    # entity      - An object that behaves as an EntityStore::Entity (see mixin)
    #
    # Returns String id of the entity
    def add_entity(entity)
      sql = "INSERT INTO entities(type, version) VALUES (:type, :version);"
      new_id = nil
      use_store do |db|
        db.executeUpdate(sql, withParameterDictionary:{ type: entity.type, version: entity.version })
        new_id = db.lastInsertRowId
      end
      new_id.to_s
    end

    # Public - saves the entity 
    # 
    # entity      - An object that behaves as an EntityStore::Entity (see mixin)
    # 
    # Returns nothing
    def save_entity(entity)
      update_entity_sql = "UPDATE entities SET version = :version WHERE id = :id"

      use_store do |db|
        db.executeUpdate(update_entity_sql, withParameterDictionary:{ version: entity.version, id: entity.id.to_i})
      end
    end

    # Public - retrieves the entity attributes and returns an empty instance
    # of the appropriate type
    # 
    # id                - String identifying the entity
    # raise_exception   - raise an exception if not found default(false)
    # 
    # Returns an instance of the entity
    def get_entity(id, raise_exception=false)
      get_entity_sql = "SELECT id, type, version, snapshot FROM entities WHERE id = :id"

      attrs = nil

      use_store do |db|
        result = db.executeQuery(get_entity_sql, withParameterDictionary:{ id: id.to_i })
        if result.next && result.intForColumn('id')
          attrs = {
            id: id,
            version: result.intForColumn('version'),
            type: result.stringForColumn('type')
          }
          if snapshot = result.UTF8StringForColumnName('snapshot')
            attrs = attrs.merge(BW::JSON.parse(snapshot))
          end
        end
        result.close
      end
      return EntityStore::Config.load_type(attrs[:type]).new(attrs) if attrs
    end

    # Public - adds an event to the store
    # 
    # event           - An object that behaves as an EntityStore::Event (see mixin)
    # 
    # Returns nothing
    def add_event(event)
      insert_event_sql = "INSERT INTO entity_events (type, entity_id, attributes) VALUES (:type, :entity_id, :attributes);"

      attributes = hash_to_json event.attributes

      use_store do |db|
        db.executeUpdate(insert_event_sql, withParameterDictionary:{ type: event.class.name, entity_id: event.entity_id, attributes: attributes })
      end
    end

    # Public - returns all events in time sequence since the version if passed otherwise all
    #
    # entity_id       - String id of the entity
    # since_version   - Fixnum version of the entity
    #
    # Returns Array of event objects
    def get_events(entity_id, since_version=nil)
      events = []

      get_events_sql = "SELECT type, attributes FROM entity_events WHERE entity_id = :entity_id ORDER BY id;"

      use_store do |db|
        results = db.executeQuery(get_events_sql, withParameterDictionary:{ entity_id: entity_id.to_i })
        while results.next do
          attributes_hash = BW::JSON.parse results.UTF8StringForColumnName('attributes')
          events << EntityStore::Config.load_type(results.stringForColumn('type')).new(attributes_hash)
        end
        results.close
      end
      events
    end

    # Public - create a snapshot of an entity. Assumes the entity has
    # already been added to the store
    # 
    # entity        -  An object that behaves as an EntityStore::Entity (see mixin)
    def snapshot_entity(entity)
      sql = "UPDATE entities SET snapshot = :snapshot WHERE id = :id;"

      attributes = hash_to_json entity.attributes

      use_store do |db|
        db.executeUpdate(sql, withParameterDictionary:{ id: entity.id.to_i, snapshot: attributes })
      end
    end

    # Public - removes the snapshot of an entity
    # 
    # id            - String id of entity
    #
    # Returns nothing
    def remove_entity_snapshot(id)
      sql = "UPDATE entities SET snapshot = NULL WHERE id = :id;"

      use_store do |db|
        db.executeUpdate(sql, withParameterDictionary:{ id: id.to_i })
      end
    end

    # Public - idempotent init operation for the data store for generating any schema
    #
    def open
      create_entity_table_sql = "CREATE TABLE IF NOT EXISTS entities "\
          "(id INTEGER PRIMARY KEY AUTOINCREMENT, type TEXT NOT NULL, "\
          "version INTEGER NOT NULL, snapshot BLOB NULL);"

        create_events_table_sql = "CREATE TABLE IF NOT EXISTS entity_events "\
            "(id INTEGER PRIMARY KEY AUTOINCREMENT, type TEXT NOT NULL, "\
            "entity_id TEXT NOT NULL, attributes BLOB NOT NULL);"

      use_store do |db|
        db.executeUpdate(create_entity_table_sql)
        db.executeUpdate(create_events_table_sql)
      end
    end

    def clear
      use_store do |db|
        db.executeUpdate("DELETE FROM entities;")
        db.executeUpdate("DELETE FROM entity_events;")
      end
    end

    def drop
      use_store do |db|
        db.executeUpdate("DROP TABLE entities;")
        db.executeUpdate("DROP TABLE entity_events;")
      end
    end

  private

    # Private: performs any data type conversions to support a successfully
    # serialisation as json. This is very naive but serves current needs
    #
    # - Times are converted to string
    #
    def hash_to_json(hash)
      hash.each_pair do |k,v|
        case v
        when Time
          hash[k] = v.string_with_format :iso8601
        end
      end
      BW::JSON.generate hash
    end
  end
end