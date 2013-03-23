require 'entity_stormotion/version'

ENTITY_STORE_FILES = %w(logging config entity entity_value event store event_data_object event_bus not_found hash_serialization attributes)

ENTITY_STORE_FILES.each do |file_name|
  BW.require "entity_store/lib/entity_store/#{file_name}.rb"
end

GEM_FILES = %w(sqlite_entity_store hash_serialization)

GEM_FILES.each do |file_name|
  BW.require "motion/#{file_name}.rb"
end

module EntityStormotion

end
