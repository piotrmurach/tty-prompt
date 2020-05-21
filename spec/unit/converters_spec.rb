# frozen_string_literal: true

RSpec.describe TTY::Prompt::Converters do
  context ":boolean" do
    {
      "t" => true,
      "f" => false,
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
      "1-10" => 1..10,
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
end
