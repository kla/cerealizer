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
require_relative "../test/models/order"
require_relative "../test/models/item"
require_relative "../test/models/user"
require_relative "../test/factories"
require_relative "../test/database"

class Setup
  include Database
  include Factories

  def self.benchmark(classes, iterations)
    iterations = (iterations.presence || 10000).to_i
    puts "Running #{iterations} iterations"

    Benchmark.bm do |x|
      classes.shuffle.each do |klass|
        x.report(klass) do
          iterations.times do
            json = klass.const_get("OrderSerializer").new(Order.last).to_json
            puts " - #{json.class}: #{json}" if iterations == 1
          end
        end
      end
    end
  end
end

Setup.setup_database
Setup.create_tables
Setup.new.create_order
