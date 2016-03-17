module GlobalRegistry
  class EntityType < Base
    # This doesn't do any paging yet since, but we can add it later if needed.
    def self.for_names(names)
      get_all_pages('filters[name][]' => names)['entity_types']
    end
  end
end
