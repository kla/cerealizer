require "test_helper"

class HashWriterTest < TestCase
  let(:writer) { Cerealizer::HashWriter.new }

  it "writes a simple hash" do
    writer.push_object("foo")
    writer.push_value("bar", "baz")
    writer.push_value(1, "number")
    writer.push_value(true, "bool")
    assert_equal "bar", writer.value["foo"]["baz"]
    assert_equal 1, writer.value["foo"]["number"]
    assert_equal true, writer.value["foo"]["bool"]
  end

  it "writes a nested object" do
    writer.push_object("foo")
    writer.push_value("bar", "baz")
    writer.push_object("nested")
    writer.push_value("qux", "quux")
    assert_equal '{"foo"=>{"baz"=>"bar", "nested"=>{"quux"=>"qux"}}}', writer.value.inspect

    writer.pop
    writer.push_value("blah", "bleh")
    assert_equal '{"foo"=>{"baz"=>"bar", "nested"=>{"quux"=>"qux"}, "bleh"=>"blah"}}', writer.value.inspect
  end

  it "can push a nil object" do
    writer.push_object(nil)
    writer.push_value("bar", "baz")
    assert_equal "bar", writer.value[nil]["baz"]
  end

  it "can push an array" do
    writer.push_object("foo")
    writer.push_value("bar", "baz")
    writer.push_array("array")
    assert_equal '{"foo"=>{"baz"=>"bar", "array"=>[]}}', writer.value.inspect

    writer.push_object(nil)
    writer.push_value("bar", "baz")
    writer.push_object("nested")
    writer.push_value("qux", "quux")
    assert_equal '{"foo"=>{"baz"=>"bar", "array"=>[{"baz"=>"bar", "nested"=>{"quux"=>"qux"}}]}}', writer.value.inspect

    writer.pop
    writer.push_value("blah", "bleh")
    assert_equal '{"foo"=>{"baz"=>"bar", "array"=>[{"baz"=>"bar", "nested"=>{"quux"=>"qux"}, "bleh"=>"blah"}]}}', writer.value.inspect

    writer.pop
    writer.push_object(nil)
    writer.push_value("bar", "baz")
    assert_equal 2, writer.value["foo"]["array"].length
    assert_equal '{"foo"=>{"baz"=>"bar", "array"=>[{"baz"=>"bar", "nested"=>{"quux"=>"qux"}, "bleh"=>"blah"}, {"baz"=>"bar"}]}}', writer.value.inspect

    writer.pop
    writer.pop
    writer.push_value("eh", "eh")
    assert_equal '{"foo"=>{"baz"=>"bar", "array"=>[{"baz"=>"bar", "nested"=>{"quux"=>"qux"}, "bleh"=>"blah"}, {"baz"=>"bar"}], "eh"=>"eh"}}', writer.value.inspect
  end

  it "can push a nil value" do
    writer.push_object("foo")
    writer.push_value(nil, "baz")
    assert_equal '{"foo"=>{"baz"=>nil}}', writer.value.inspect
  end
end
