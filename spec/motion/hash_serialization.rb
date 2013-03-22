module EntityStore
  module HashSerialization

    # Override to cope with the different way RubyMotion describes public methods
    # ie with colon suffix
    def attribute_methods
      public_methods
        .select { |m| m =~ /\w\=:$/ }
        .collect { |m| m.to_s.chomp('=:').to_sym }
        .select { |m| respond_to?(m) }
    end
  end
end