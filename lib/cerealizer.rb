require "multi_json"
require "oj"

module Cerealizer
  autoload :Base, "cerealizer/base"
  autoload :Attribute, "cerealizer/attribute"
  autoload :HashWriter, "cerealizer/hash_writer"
  autoload :JsonStringWriter, "cerealizer/json_string_writer"
  autoload :VERSION, "cerealizer/version"
end
