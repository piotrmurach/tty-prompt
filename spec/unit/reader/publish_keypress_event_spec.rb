# encoding: utf-8

RSpec.describe TTY::Prompt::Reader, '#publish_keypress_event' do
  let(:input)  { StringIO.new }
  let(:out) { StringIO.new }
  let(:reader) { described_class.new(input, out) }

  it "publishes :keypress events" do
    input << "abc\n"
    input.rewind
    chars = []
    reader.on(:keypress) { |char| chars << char }
    answer = reader.read_line
    expect(chars).to eq(%w(a b c))
    expect(answer).to eq("abc")
  end

  it "publishes :keyup for read_keypress" do
    input << "\e[Aaa"
    input.rewind
    keys = []
    reader.on(:keypress) { |key| keys << "keypress_#{key}" }
    reader.on(:keyup)    { |key| keys << "keyup_#{key}" }
    reader.on(:keydown)  { |key| keys << "keydown_#{key}" }

    answer = reader.read_keypress
    expect(keys).to eq(["keyup_\e[A", "keypress_\e[A"])
    expect(answer).to eq("\e[A")
  end

  it "publishes :keydown event for read_keypress" do
    input << "\e[Baa"
    input.rewind
    keys = []
    reader.on(:keypress) { |key| keys << "keypress_#{key}" }
    reader.on(:keyup)    { |key| keys << "keyup_#{key}" }
    reader.on(:keydown)  { |key| keys << "keydown_#{key}" }

    answer = reader.read_keypress
    expect(keys).to eq(["keydown_\e[B", "keypress_\e[B"])
    expect(answer).to eq("\e[B")
  end

  it "publishes :keynum event" do
    input << "5aa"
    input.rewind
    keys = []
    reader.on(:keypress) { |key| keys << "keypress_#{key}" }
    reader.on(:keyup)    { |key| keys << "keyup_#{key}" }
    reader.on(:keynum)   { |key| keys << "keynum_#{key}" }

    answer = reader.read_keypress
    expect(keys).to eq(["keynum_5", "keypress_5"])
    expect(answer).to eq("5")
  end

  it "publishes :keyspace event" do
    input << "\r"
    input.rewind
    keys = []
    reader.on(:keypress) { |key| keys << "keypress" }
    reader.on(:keyup)    { |key| keys << "keyup" }
    reader.on(:keyreturn) { |key| keys << "keyreturn" }

    answer = reader.read_keypress
    expect(keys).to eq(["keyreturn", "keypress"])
    expect(answer).to eq("\r")
  end

  it "subscribes to multiple events" do
    input << "\n"
    input.rewind
    keys = []
    reader.on(:keyenter) { |key| keys << "keyenter" }
          .on(:keypress) { |key| keys << "keypress" }

    answer = reader.read_keypress
    expect(keys).to eq(["keyenter", "keypress"])
    expect(answer).to eq("\n")
  end
end
