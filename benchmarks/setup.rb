require "bundler/setup"
require "active_support"
require "active_record"
require "action_view"
require "action_controller"
require "cerealizer"
require "active_model_serializers"
require "jsonapi/serializer"
require "jbuilder"
require "alba"
require "panko_serializer"
require "ruby-prof"
require_relative "../test/models/order"
require_relative "../test/models/item"
require_relative "../test/models/user"
require_relative "../test/factories"
require_relative "../test/database"

class Setup
  include Database
  include Factories

  def self.benchmark(klass, iterations, profile)
    RubyProf.start if profile
    begin_at = Time.now
    order = Order.first
    name = klass.to_s.gsub("Serializers::", "")
    iterations.times do
      json = klass.const_get("OrderSerializer").serialize(order.reload)
      raise "Expected JSON to be a String" unless json.is_a?(String)
      puts "#{name}, #{json}" if iterations == 1
    end

    time = { serializer: name, total: Time.now - begin_at }
    puts time.to_json if iterations > 1

    if profile
      results = RubyProf.stop
      RubyProf::CallTreePrinter.new(results).print
      FileUtils.mv("profile.callgrind.out.#{Process.pid}", "../callgrind.txt")
    end
  end
end

Setup.setup_database
Setup.create_tables
Setup.new.create_order
