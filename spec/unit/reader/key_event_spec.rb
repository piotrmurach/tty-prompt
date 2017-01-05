# encoding: utf-8

require 'shellwords'
require 'tty/prompt/reader/codes'

RSpec.describe TTY::Prompt::Reader::KeyEvent, '#from' do
  let(:keys) { TTY::Prompt::Reader::Codes.keys }

  it "parses backspace" do
    event = described_class.from(keys, [127])
    expect(event.key.name).to eq(:backspace)
    expect(event.value).to eq("\x7f")
  end

  it "parses lowercase char" do
    event = described_class.from(keys, [97])
    expect(event.key.name).to eq(:alpha)
    expect(event.value).to eq('a')
  end

  it "parses uppercase char" do
    event = described_class.from(keys, [65])
    expect(event.key.name).to eq(:alpha)
    expect(event.value).to eq('A')
  end

  it "parses ctrl-a to ctrl-z inputs" do
    (1..26).zip('a'..'z').each do |code, char|
      next if ['i', 'j', 'm'].include?(char)
      event = described_class.from(keys, [code])
      expect(event.key.name).to eq(:"ctrl_#{char}")
      expect(event.value).to eq([code].pack('U*'))
    end
  end

  # F1-F12 keys
  {
    f1:  ["\eOP".bytes.to_a, "\e[11~".bytes.to_a],
    f2:  ["\eOQ".bytes.to_a, "\e[12~".bytes.to_a],
    f3:  ["\eOR".bytes.to_a, "\e[13~".bytes.to_a],
    f4:  ["\eOS".bytes.to_a, "\e[14~".bytes.to_a],
    f5:  [                   "\e[15~".bytes.to_a],
    f6:  [                   "\e[17~".bytes.to_a],
    f7:  [                   "\e[18~".bytes.to_a],
    f8:  [                   "\e[19~".bytes.to_a],
    f9:  [                   "\e[20~".bytes.to_a],
    f10: [                   "\e[21~".bytes.to_a],
    f11: [                   "\e[23~".bytes.to_a],
    f12: [                   "\e[24~".bytes.to_a]
  }.each do |name, codes|
    codes.each do |code|
      it "parses #{Shellwords.escape(code)} as #{name} key" do
        event = described_class.from(keys, code)
        expect(event.key.name).to eq(name)
        expect(event.key.meta).to eq(false)
        expect(event.key.ctrl).to eq(false)
        expect(event.key.shift).to eq(false)
      end
    end
  end

  # arrow keys & page navigation
  {
    up:    ["\e[A".bytes.to_a],
    down:  ["\e[B".bytes.to_a],
    right: ["\e[C".bytes.to_a],
    left:  ["\e[D".bytes.to_a],
    clear: ["\e[E".bytes.to_a],
    end:   ["\e[F".bytes.to_a],
    home:  ["\e[H".bytes.to_a]
  }.each do |name, codes|
    codes.each do |code|
      it "parses #{Shellwords.escape(code)} as #{name} key" do
        event = described_class.from(keys, code)
        expect(event.key.name).to eq(name)
        expect(event.key.meta).to eq(false)
        expect(event.key.ctrl).to eq(false)
        expect(event.key.shift).to eq(false)
      end
    end
  end
end
