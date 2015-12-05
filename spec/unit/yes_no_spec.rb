# encoding: utf-8

RSpec.describe TTY::Prompt, '#yes?' do

  subject(:prompt) { TTY::TestPrompt.new }

  context 'yes?' do
    it 'agrees' do
      prompt.input << 'yes'
      prompt.input.rewind
      expect(prompt.yes?("Are you a human?")).to eq(true)
      expect(prompt.output.string).to eq([
        "Are you a human? ",
        "\e[1A\e[1000D\e[K",
        "Are you a human? \e[32myes\e[0m"
      ].join)
    end

    it 'disagrees' do
      prompt.input << 'no'
      prompt.input.rewind
      expect(prompt.yes?("Are you a human?")).to eq(false)
      expect(prompt.output.string).to eq([
        "Are you a human? ",
        "\e[1A\e[1000D\e[K",
        "Are you a human? \e[32mno\e[0m"
      ].join)
    end
  end

  context 'no?' do
    it 'disagrees' do
      prompt.input << 'no'
      prompt.input.rewind
      expect(prompt.no?("Are you a human?")).to eq(true)
      expect(prompt.output.string).to eq([
        "Are you a human? ",
        "\e[1A\e[1000D\e[K",
        "Are you a human? \e[32mno\e[0m"
      ].join)
    end

    it 'agrees' do
      prompt.input << 'yes'
      prompt.input.rewind
      expect(prompt.no?("Are you a human?")).to eq(false)
      expect(prompt.output.string).to eq([
        "Are you a human? ",
        "\e[1A\e[1000D\e[K",
        "Are you a human? \e[32myes\e[0m"
      ].join)
    end
  end
end
