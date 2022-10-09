module Cerealizer
  class SerializationOptions
    attr_reader :include_root
    attr_reader :exclude_associations

    def initialize(options)
      @include_root = !!options[:include_root]
      @exclude_associations = !!options[:exclude_associations]
    end
  end
end
