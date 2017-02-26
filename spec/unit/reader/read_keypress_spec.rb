# encoding: utf-8

RSpec.describe TTY::Prompt::Reader, '#read_keypress' do
  let(:input)  { StringIO.new }
  let(:out)    { StringIO.new }
  let(:env)    { { "TTY_TEST" => true } }

  it "reads single key press" do
    reader = described_class.new(input, out, env: env)
    input << "\e[Aaaaaaa\n"
    input.rewind

    answer = reader.read_keypress

    expect(answer).to eq("\e[A")
  end

  it 'reads multibyte key press' do
    reader = described_class.new(input, out, env: env)
    input << "ㄱ"
    input.rewind

    answer = reader.read_keypress

    expect(answer).to eq("ㄱ")
  end

  context 'when Ctrl+C pressed' do
    it "defaults to raising InputInterrupt" do
      reader = described_class.new(input, out, env: env)
      input << "\x03"
      input.rewind

      expect {
        reader.read_keypress
      }.to raise_error(TTY::Prompt::Reader::InputInterrupt)
    end

    it "sends interrupt signal when :signal option is chosen" do
      reader = described_class.new(input, out, interrupt: :signal, env: env)
      input << "\x03"
      input.rewind

      allow(Process).to receive(:pid).and_return(666)
      allow(Process).to receive(:kill)
      expect(Process).to receive(:kill).with('SIGINT', 666)

      reader.read_keypress
    end

    it "exits with 130 code when :exit option is chosen" do
      reader = described_class.new(input, out, interrupt: :exit, env: env)
      input << "\x03"
      input.rewind

      expect {
        reader.read_keypress
      }.to raise_error(SystemExit)
    end

    it "evaluates custom handler when proc object is provided" do
      handler = proc { raise ArgumentError }
      reader = described_class.new(input, out, interrupt: handler, env: env)
      input << "\x03"
      input.rewind

      expect {
       reader.read_keypress
      }.to raise_error(ArgumentError)
    end

    it "skips handler when handler is nil" do
      reader = described_class.new(input, out, interrupt: :noop, env: env)
      input << "\x03"
      input.rewind

      expect(reader.read_keypress).to eq("\x03")
    end
  end
end
