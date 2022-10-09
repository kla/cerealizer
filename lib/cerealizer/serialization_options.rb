module Cerealizer
  class SerializationOptions
    attr_reader :include_root
    attr_reader :exclude_associations
    attr_reader :except

    def initialize(options)
      @include_root = !!options[:include_root]
      @exclude_associations = !!options[:exclude_associations]
      @except = options[:except] ? Array(options[:except]).map(&:to_s) : nil
    end
  end
end
