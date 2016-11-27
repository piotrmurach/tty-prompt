# encoding: utf-8

require 'shellwords'

RSpec.describe TTY::Prompt::Reader::KeyEvent, '#from' do
  it "parses ctrl+h" do
    event = described_class.from("\b")
    expect(event.key.name).to eq(:backspace)
    expect(event.value).to eq("\b")
  end

  it "parses backspace" do
    event = described_class.from("\e\x7f")
    expect(event.key.name).to eq(:backspace)
    expect(event.key.meta).to eq(true)
    expect(event.value).to eq("\e\x7f")
  end

  it "parses lowercase char" do
    event = described_class.from('a')
    expect(event.key.name).to eq('a')
    expect(event.value).to eq('a')
  end

  it "parses uppercase char" do
    event = described_class.from('A')
    expect(event.key.name).to eq('a')
    expect(event.value).to eq('A')
  end

  # F1-F12 keys
  {
    f1:  ["\eOP", "\e[11~", "\e[[A"],
    f2:  ["\eOQ", "\e[12~", "\e[[B"],
    f3:  ["\eOR", "\e[13~", "\e[[C"],
    f4:  ["\eOS", "\e[14~", "\e[[D"],
    f5:  [        "\e[15~", "\e[[E"],
    f6:  [        "\e[17~"         ],
    f7:  [        "\e[18~"         ],
    f8:  [        "\e[19~"         ],
    f9:  [        "\e[20~"         ],
    f10: [        "\e[21~"         ],
    f11: [        "\e[23~"         ],
    f12: [        "\e[24~"         ]
  }.each do |name, codes|
    codes.each do |code|
      it "parses #{Shellwords.escape(code)} as #{name} key" do
        event = described_class.from(code)
        expect(event.key.name).to eq(name)
        expect(event.key.meta).to eq(false)
        expect(event.key.ctrl).to eq(false)
        expect(event.key.shift).to eq(false)
      end
    end
  end

  # arrow keys & page navigation
  #
  {
    up:    ["\e[A", "\eOA"],
    down:  ["\e[B", "\eOB"],
    right: ["\e[C", "\eOC"],
    left:  ["\e[D", "\eOD"],
    clear: ["\e[E", "\eOE"],
    end:   ["\e[F"],
    home:  ["\e[H"]
  }.each do |name, codes|
    codes.each do |code|
      it "parses #{Shellwords.escape(code)} as #{name} key" do
        event = described_class.from(code)
        expect(event.key.name).to eq(name)
        expect(event.key.meta).to eq(false)
        expect(event.key.ctrl).to eq(false)
        expect(event.key.shift).to eq(false)
      end
    end
  end

  {
    up:    ["\e[a"],
    down:  ["\e[b"],
    right: ["\e[c"],
    left:  ["\e[d"],
    clear: ["\e[e"],
  }.each do |name, codes|
    codes.each do |code|
      it "parses #{Shellwords.escape(code)} as SHIFT + #{name} key" do
        event = described_class.from(code)
        expect(event.key.name).to eq(name)
        expect(event.key.meta).to eq(false)
        expect(event.key.ctrl).to eq(false)
        expect(event.key.shift).to eq(true)
      end
    end
  end
end
