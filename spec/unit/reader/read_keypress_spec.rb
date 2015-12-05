# encoding: utf-8

RSpec.describe TTY::Prompt::Reader, '#read_keypress' do
  let(:input)  { StringIO.new }
  let(:out) { StringIO.new }
  let(:reader) { described_class.new(input, out) }

  it "reads single key press" do
    input << "\e[Aaaaaaa\n"
    input.rewind
    answer = reader.read_keypress
    expect(answer).to eq("\e[A")
  end

  it "stops reading when ctrl-c pressed" do
    input << "\x03"
    input.rewind
    expect {
      reader.read_keypress
    }.to raise_error(SystemExit)
  end
end
