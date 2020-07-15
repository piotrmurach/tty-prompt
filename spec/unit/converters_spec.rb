# frozen_string_literal: true

require "pathname"
require "date"
require "time"
require "uri"

RSpec.describe TTY::Prompt::Converters do
  context ":boolean" do
    {
      "t" => true,
      "true" => true,
      "y" => true,
      "YES" => true,
      "1" => true,
      "f" => false,
      "FALSE" => false,
      "no" => false,
      "0" => false,
      "unknown"=> TTY::Prompt::Const::Undefined
    }.each do |input, value|
      it "converts #{input.inspect} to #{value.inspect}" do
        expect(described_class.convert(:bool, input)).to eq(value)
      end
    end
  end

  context ":string" do
    {
      "" => "",
      "input\n" => "input",
    }.each do |input, value|
      it "converts #{input.inspect} to #{value.inspect}" do
        expect(described_class.convert(:str, input)).to eq(value)
      end
    end
  end

  context ":char" do
    {
      "" => nil,
      "input" => "i",
    }.each do |input, value|
      it "converts #{input.inspect} to #{value.inspect}" do
        expect(described_class.convert(:char, input)).to eq(value)
      end
    end
  end

  context ":date" do
    {
      "2020/05/21" => ::Date.parse("2020/05/21"),
      "unknown"=> TTY::Prompt::Const::Undefined
    }.each do |input, value|
      it "converts #{input.inspect} to #{value.inspect}" do
        expect(described_class.convert(:date, input)).to eq(value)
      end
    end
  end

  context ":datetime" do
    {
      "2020/05/21 11:12:13" => ::DateTime.parse("2020/05/21 11:12:13"),
      "unknown"=> TTY::Prompt::Const::Undefined,
    }.each do |input, value|
      it "converts #{input.inspect} to #{value.inspect}" do
        expect(described_class.convert(:datetime, input)).to eq(value)
      end
    end
  end

  context ":time" do
    {
      "11:12:13" => ::Time.parse("11:12:13"),
      "unknown" => TTY::Prompt::Const::Undefined
    }.each do |input, value|
      it "converts #{input.inspect} to #{value.inspect}" do
        expect(described_class.convert(:time, input)).to eq(value)
      end
    end
  end

  context ":integer" do
    {
      "12" => 12,
      "unknown"=> TTY::Prompt::Const::Undefined
    }.each do |input, value|
      it "converts #{input.inspect} to #{value.inspect}" do
        expect(described_class.convert(:int, input)).to eq(value)
      end
    end
  end

  context ":float" do
    {
      "12.3" => 12.3,
      "unknown"=> TTY::Prompt::Const::Undefined
    }.each do |input, value|
      it "converts #{input.inspect} to #{value.inspect}" do
        expect(described_class.convert(:float, input)).to eq(value)
      end
    end
  end

  context ":range" do
    {
      1..10 => 1..10,
      "1" => 1..1,
      "1.0" => 1.0..1.0,
      "1-10" => 1..10,
      "-5--1" => -5..-1,
      "1.2-5.0" => 1.2..5.0,
      "1 , 10" => 1..10,
      "1..10" => 1..10,
      "1...10" => 1...10,
      "1 . . . 10" => 1...10,
      "a..z" => "a".."z",
      "a . . . z" => "a"..."z",
      "unknown"=> TTY::Prompt::Const::Undefined
    }.each do |input, value|
      it "converts #{input.inspect} to #{value.inspect}" do
        expect(described_class.convert(:range, input)).to eq(value)
      end
    end
  end

  context ":regexp" do
    {
      '\d+' => /\d+/,
      "unknown"=> /unknown/
    }.each do |input, value|
      it "converts #{input.inspect} to #{value.inspect}" do
        expect(described_class.convert(:regexp, input)).to eq(value)
      end
    end
  end

  context ":path" do
    {
      "/foo/bar/baz" => ::Pathname.new("/foo/bar/baz")
    }.each do |input, value|
      it "converts #{input.inspect} to #{value.inspect}" do
        expect(described_class.convert(:path, input)).to eq(value)
      end
    end
  end

  context ":uri" do
    {
      "http://foobar.com" => ::URI.parse("http://foobar.com")
    }.each do |input, value|
      it "converts #{input.inspect} to #{value.inspect}" do
        expect(described_class.convert(:uri, input)).to eq(value)
      end
    end
  end

  context ":array/:list" do
    {
      ",," => [],
      ",b,c" => %w[b c],
      "a,b,c" => %w[a b c],
      "a , b , c" => %w[a b c],
      "a, , c" => %w[a c],
      "a, b\\, c" => ["a", "b, c"],
      %w[a b c] => %w[a b c],
    }.each do |input, obj|
      it "converts #{input.inspect} to #{obj.inspect}" do
        expect(described_class.convert(:array, input)).to eq(obj)
      end
    end
  end

  context ":map" do
    {
      "" => {},
      "a=1" => {a: "1"},
      "a=1&b=2" => {a: "1", b: "2"},
      "a=&b=2" => {a: "", b: "2"},
      "a=1&b=2&a=3" => {a: ["1", "3"], b: "2"},
      "a:1 b:2" => {a: "1", b: "2"},
      "a:1 b:2 a:3" => {a: ["1", "3"], b: "2"},
      %w[a:1 b:2 c:3] => {a: "1", b: "2", c: "3"},
      %w[a=1 b=2 c=3] => {a: "1", b: "2", c: "3"},
    }.each do |input, obj|
      it "converts #{input.inspect} to #{obj.inspect}" do
        expect(described_class.convert(:hash, input)).to eq(obj)
      end
    end
  end
end
