# encoding: utf-8

RSpec.describe TTY::Prompt::Reader, '#read_keypress' do
  let(:input)  { StringIO.new }
  let(:output) { StringIO.new }
  let(:reader) { described_class.new(input, output) }

  it "reads single key press" do
    input << "\e[Aaaaaaa\n"
    input.rewind
    answer = reader.read_keypress
    expect(answer).to eq("\e[A")
  end
end
