require "test_helper"

class WriterTest < TestCase
  let(:simple) do
    writer.push_object
      writer.push_object("foo")
        writer.push_value("baz", "bar")
        writer.push_value("number", 1)
        writer.push_value("bool", true)
      writer.pop
    writer.pop
    writer
  end

  let(:nested_objects) do
    writer.push_object
      writer.push_object("foo")
        writer.push_value("baz", "bar")
        writer.push_object("nested")
        writer.push_value("quux", "qux")
      writer.pop
      writer.push_value("bleh", "blah")
    writer.pop
    writer
  end

  let(:array_with_objects) do
    writer.push_object
      writer.push_object("foo")
      writer.push_value("baz", "bar")
      writer.push_array("array")
        writer.push_object
          writer.push_value("baz", "bar")
          writer.push_object("nested")
            writer.push_value("quux", "qux")
          writer.pop
          writer.push_value("bleh", "blah")
        writer.pop
        writer.push_object
          writer.push_value("baz", "bar")
        writer.pop
      writer.pop
      writer.push_value("eh", "eh")
    writer.pop
    writer
  end

  describe "a json string writer" do
    let(:writer) { Cerealizer::JsonStringWriter.new }

    it "can't push a nil object" do
      writer.push_object
      e = assert_raises(StandardError) { writer.push_object(nil) }
      assert_match(/Can not push onto an Object without a key/, e.message)
    end

    it "can build a simple object" do
      assert_equal '{"foo":{"baz":"bar","number":1,"bool":true}}', simple.value
    end

    it "can build a nested object" do
      assert_equal '{"foo":{"baz":"bar","nested":{"quux":"qux"},"bleh":"blah"}', nested_objects.value
    end

    it "can build an array with objects" do
      assert_equal '{"foo":{"baz":"bar","array":[{"baz":"bar","nested":{"quux":"qux"},"bleh":"blah"},{"baz":"bar"}],"eh":"eh"}', array_with_objects.value
    end
  end

  describe "a hash writer" do
    let(:writer) { Cerealizer::HashWriter.new }

    it "can build a simple object" do
      assert_equal '{"foo"=>{"baz"=>"bar", "number"=>1, "bool"=>true}}', simple.value.inspect
    end

    it "can build a nested object" do
      assert_equal '{"foo"=>{"baz"=>"bar", "nested"=>{"quux"=>"qux"}, "bleh"=>"blah"}}', nested_objects.value.inspect
    end

    it "can build an array with objects" do
      assert_equal '{"foo"=>{"baz"=>"bar", "array"=>[{"baz"=>"bar", "nested"=>{"quux"=>"qux"}, "bleh"=>"blah"}, {"baz"=>"bar"}], "eh"=>"eh"}}', array_with_objects.value.inspect
    end
  end
end
