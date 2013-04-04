# Provide an implementation of the parse method that isn't available 
# on RubyMotion
module EntityStore
  module TimeFactory
    def self.parse(value)
      Time.iso8601(value)
    end
  end
end