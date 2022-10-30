module Cerealizer
  class SerializationOptions
    attr_reader :include_root
    attr_reader :exclude_associations
    attr_reader :except
    attr_reader :only
    attr_reader :params

    def initialize(options)
      return unless options
      @include_root = !!options[:include_root]
      @exclude_associations = !!options[:exclude_associations]
      @except = options[:except] ? Array(options[:except]).map(&:to_s) : nil
      @only = options[:only] ? Array(options[:only]).map(&:to_s) : nil
      @params = options[:params] || { }
    end
  end
end
