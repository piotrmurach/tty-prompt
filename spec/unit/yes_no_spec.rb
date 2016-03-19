# encoding: utf-8

RSpec.describe TTY::Prompt, 'confirmation' do

  subject(:prompt) { TTY::TestPrompt.new }

  context '#yes?' do
    it 'agrees with question' do
      prompt.input << 'yes'
      prompt.input.rewind
      expect(prompt.yes?("Are you a human?")).to eq(true)
      expect(prompt.output.string).to eq([
        "Are you a human? \e[90m(Y/n)\e[0m ",
        "\e[1000D\e[K\e[1A",
        "\e[1000D\e[K",
        "Are you a human? \e[32mYes\e[0m\n"
      ].join)
    end

    it 'disagrees with question' do
      prompt.input << 'no'
      prompt.input.rewind
      expect(prompt.yes?("Are you a human?")).to eq(false)
      expect(prompt.output.string).to eq([
        "Are you a human? \e[90m(Y/n)\e[0m ",
        "\e[1000D\e[K\e[1A",
        "\e[1000D\e[K",
        "Are you a human? \e[32mNo\e[0m\n"
      ].join)
    end

    it 'assumes default true' do
      prompt.input << "\r"
      prompt.input.rewind
      expect(prompt.yes?("Are you a human?")).to eq(true)
      expect(prompt.output.string).to eq([
        "Are you a human? \e[90m(Y/n)\e[0m ",
        "\e[1000D\e[K\e[1A",
        "\e[1000D\e[K",
        "Are you a human? \e[32mYes\e[0m\n"
      ].join)
    end

    it "customizes question through options" do
      prompt.input << "\r"
      prompt.input.rewind
      result = prompt.yes?("Are you a human?", suffix: 'Agree/Disagree',
                            positive: 'Agree', negative: 'Disagree')
      expect(result).to eq(true)
      expect(prompt.output.string).to eq([
        "Are you a human? \e[90m(Agree/Disagree)\e[0m ",
        "\e[1000D\e[K\e[1A",
        "\e[1000D\e[K",
        "Are you a human? \e[32mAgree\e[0m\n"
      ].join)
    end

    it "customizes question through DSL" do
      prompt.input << "disagree\r"
      prompt.input.rewind
      conversion = proc { |input| !input.match(/^agree$/i).nil? }
      result = prompt.yes?("Are you a human?") do |q|
                 q.suffix 'Agree/Disagree'
                 q.positive 'Agree'
                 q.negative 'Disagree'
                 q.convert conversion
               end
      expect(result).to eq(false)
      expect(prompt.output.string).to eq([
        "Are you a human? \e[90m(Agree/Disagree)\e[0m ",
        "\e[1000D\e[K\e[1A",
        "\e[1000D\e[K",
        "Are you a human? \e[32mDisagree\e[0m\n"
      ].join)
    end
  end

  context '#no?' do
    it 'agrees with question' do
      prompt.input << 'no'
      prompt.input.rewind
      expect(prompt.no?("Are you a human?")).to eq(true)
      expect(prompt.output.string).to eq([
        "Are you a human? \e[90m(y/N)\e[0m ",
        "\e[1000D\e[K\e[1A",
        "\e[1000D\e[K",
        "Are you a human? \e[32mNo\e[0m\n"
      ].join)
    end

    it 'disagrees with question' do
      prompt.input << 'yes'
      prompt.input.rewind
      expect(prompt.no?("Are you a human?")).to eq(false)
      expect(prompt.output.string).to eq([
        "Are you a human? \e[90m(y/N)\e[0m ",
        "\e[1000D\e[K\e[1A",
        "\e[1000D\e[K",
        "Are you a human? \e[32mYes\e[0m\n"
      ].join)
    end

    it 'assumes default false' do
      prompt.input << "\r"
      prompt.input.rewind
      expect(prompt.no?("Are you a human?")).to eq(true)
      expect(prompt.output.string).to eq([
        "Are you a human? \e[90m(y/N)\e[0m ",
        "\e[1000D\e[K\e[1A",
        "\e[1000D\e[K",
        "Are you a human? \e[32mNo\e[0m\n"
      ].join)
    end

    it "customizes question through DSL" do
      prompt.input << "agree\r"
      prompt.input.rewind
      conversion = proc { |input| !input.match(/^agree$/i).nil? }
      result = prompt.no?("Are you a human?") do |q|
                 q.suffix 'Agree/Disagree'
                 q.positive 'Agree'
                 q.negative 'Disagree'
                 q.convert conversion
               end
      expect(result).to eq(false)
      expect(prompt.output.string).to eq([
        "Are you a human? \e[90m(Agree/Disagree)\e[0m ",
        "\e[1000D\e[K\e[1A",
        "\e[1000D\e[K",
        "Are you a human? \e[32mAgree\e[0m\n"
      ].join)
    end
  end
end
