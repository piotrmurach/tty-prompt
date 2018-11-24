# frozen_string_literal: true

RSpec.describe TTY::Prompt, 'confirmation' do

  subject(:prompt) { TTY::TestPrompt.new }

  context '#yes?' do
    it 'agrees with question' do
      prompt.input << 'yes'
      prompt.input.rewind
      expect(prompt.yes?("Are you a human?")).to eq(true)
      expect(prompt.output.string).to eq([
        "Are you a human? \e[90m(Y/n)\e[0m ",
        "\e[2K\e[1GAre you a human? \e[90m(Y/n)\e[0m y",
        "\e[2K\e[1GAre you a human? \e[90m(Y/n)\e[0m ye",
        "\e[2K\e[1GAre you a human? \e[90m(Y/n)\e[0m yes",
        "\e[1A\e[2K\e[1G",
        "Are you a human? \e[32mYes\e[0m\n"
      ].join)
    end

    it 'disagrees with question' do
      prompt.input << 'no'
      prompt.input.rewind
      expect(prompt.yes?("Are you a human?")).to eq(false)
      expect(prompt.output.string).to eq([
        "Are you a human? \e[90m(Y/n)\e[0m ",
        "\e[2K\e[1GAre you a human? \e[90m(Y/n)\e[0m n",
        "\e[2K\e[1GAre you a human? \e[90m(Y/n)\e[0m no",
        "\e[1A\e[2K\e[1G",
        "Are you a human? \e[32mno\e[0m\n"
      ].join)
    end

    it 'assumes default true' do
      prompt.input << "\r"
      prompt.input.rewind
      expect(prompt.yes?("Are you a human?")).to eq(true)
      expect(prompt.output.string).to eq([
        "Are you a human? \e[90m(Y/n)\e[0m ",
        "\e[2K\e[1GAre you a human? \e[90m(Y/n)\e[0m \n",
        "\e[1A\e[2K\e[1G",
        "Are you a human? \e[32mYes\e[0m\n"
      ].join)
    end

    it 'changes default' do
      prompt.input << "\n"
      prompt.input.rewind
      expect(prompt.yes?("Are you a human?", default: false)).to eq(false)
      expect(prompt.output.string).to eq([
        "Are you a human? \e[90m(y/N)\e[0m ",
        "\e[2K\e[1GAre you a human? \e[90m(y/N)\e[0m \n",
        "\e[1A\e[2K\e[1G",
        "Are you a human? \e[32mNo\e[0m\n"
      ].join)
    end

    it "defaults suffix and converter" do
      prompt.input << "Nope\n"
      prompt.input.rewind
      result = prompt.yes?("Are you a human?") do |q|
        q.positive 'Yup'
        q.negative 'nope'
      end
      expect(result).to eq(false)
      expect(prompt.output.string).to eq([
        "Are you a human? \e[90m(Yup/nope)\e[0m ",
        "\e[2K\e[1GAre you a human? \e[90m(Yup/nope)\e[0m N",
        "\e[2K\e[1GAre you a human? \e[90m(Yup/nope)\e[0m No",
        "\e[2K\e[1GAre you a human? \e[90m(Yup/nope)\e[0m Nop",
        "\e[2K\e[1GAre you a human? \e[90m(Yup/nope)\e[0m Nope",
        "\e[2K\e[1GAre you a human? \e[90m(Yup/nope)\e[0m Nope\n",
        "\e[1A\e[2K\e[1G",
        "Are you a human? \e[32mnope\e[0m\n"
      ].join)
    end

    it "defaults positive and negative" do
      prompt.input << "Nope\n"
      prompt.input.rewind
      result = prompt.yes?("Are you a human?") do |q|
        q.suffix 'Yup/nope'
      end
      expect(result).to eq(false)
      expect(prompt.output.string).to eq([
        "Are you a human? \e[90m(Yup/nope)\e[0m ",
        "\e[2K\e[1GAre you a human? \e[90m(Yup/nope)\e[0m N",
        "\e[2K\e[1GAre you a human? \e[90m(Yup/nope)\e[0m No",
        "\e[2K\e[1GAre you a human? \e[90m(Yup/nope)\e[0m Nop",
        "\e[2K\e[1GAre you a human? \e[90m(Yup/nope)\e[0m Nope",
        "\e[2K\e[1GAre you a human? \e[90m(Yup/nope)\e[0m Nope\n",
        "\e[1A\e[2K\e[1G",
        "Are you a human? \e[32mnope\e[0m\n"
      ].join)
    end

    it "accepts regex conflicting characters as suffix" do
      prompt.input << "]\n"
      prompt.input.rewind
      result = prompt.yes?("Are you a human? [ as yes and ] as no") do |q|
        q.suffix "[/]"
      end
      expect(result).to eq(false)
      expect(prompt.output.string).to eq([
        "Are you a human? [ as yes and ] as no \e[90m([/])\e[0m ",
        "\e[2K\e[1GAre you a human? [ as yes and ] as no \e[90m([/])\e[0m ]",
        "\e[2K\e[1GAre you a human? [ as yes and ] as no \e[90m([/])\e[0m ]\n",
        "\e[1A\e[2K\e[1G",
        "Are you a human? [ as yes and ] as no \e[32m]\e[0m\n"
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
        "\e[2K\e[1GAre you a human? \e[90m(Agree/Disagree)\e[0m \n",
        "\e[1A\e[2K\e[1G",
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
        "\e[2K\e[1GAre you a human? \e[90m(Agree/Disagree)\e[0m d",
        "\e[2K\e[1GAre you a human? \e[90m(Agree/Disagree)\e[0m di",
        "\e[2K\e[1GAre you a human? \e[90m(Agree/Disagree)\e[0m dis",
        "\e[2K\e[1GAre you a human? \e[90m(Agree/Disagree)\e[0m disa",
        "\e[2K\e[1GAre you a human? \e[90m(Agree/Disagree)\e[0m disag",
        "\e[2K\e[1GAre you a human? \e[90m(Agree/Disagree)\e[0m disagr",
        "\e[2K\e[1GAre you a human? \e[90m(Agree/Disagree)\e[0m disagre",
        "\e[2K\e[1GAre you a human? \e[90m(Agree/Disagree)\e[0m disagree",
        "\e[2K\e[1GAre you a human? \e[90m(Agree/Disagree)\e[0m disagree\n",
        "\e[1A\e[2K\e[1G",
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
        "\e[2K\e[1GAre you a human? \e[90m(y/N)\e[0m n",
        "\e[2K\e[1GAre you a human? \e[90m(y/N)\e[0m no",
        "\e[1A\e[2K\e[1G",
        "Are you a human? \e[32mNo\e[0m\n"
      ].join)
    end

    it 'disagrees with question' do
      prompt.input << 'yes'
      prompt.input.rewind
      expect(prompt.no?("Are you a human?")).to eq(false)
      expect(prompt.output.string).to eq([
        "Are you a human? \e[90m(y/N)\e[0m ",
        "\e[2K\e[1GAre you a human? \e[90m(y/N)\e[0m y",
        "\e[2K\e[1GAre you a human? \e[90m(y/N)\e[0m ye",
        "\e[2K\e[1GAre you a human? \e[90m(y/N)\e[0m yes",
        "\e[1A\e[2K\e[1G",
        "Are you a human? \e[32myes\e[0m\n"
      ].join)
    end

    it 'assumes default false' do
      prompt.input << "\r"
      prompt.input.rewind
      expect(prompt.no?("Are you a human?")).to eq(true)
      expect(prompt.output.string).to eq([
        "Are you a human? \e[90m(y/N)\e[0m ",
        "\e[2K\e[1GAre you a human? \e[90m(y/N)\e[0m \n",
        "\e[1A\e[2K\e[1G",
        "Are you a human? \e[32mNo\e[0m\n"
      ].join)
    end

    it 'changes default' do
      prompt.input << "\r"
      prompt.input.rewind
      expect(prompt.no?("Are you a human?", default: true)).to eq(false)
      expect(prompt.output.string).to eq([
        "Are you a human? \e[90m(Y/n)\e[0m ",
        "\e[2K\e[1GAre you a human? \e[90m(Y/n)\e[0m \n",
        "\e[1A\e[2K\e[1G",
        "Are you a human? \e[32mYes\e[0m\n"
      ].join)
    end

    it "defaults suffix and converter" do
      prompt.input << "Yup\n"
      prompt.input.rewind
      result = prompt.no?("Are you a human?") do |q|
        q.positive 'yup'
        q.negative 'Nope'
      end
      expect(result).to eq(false)
      expect(prompt.output.string).to eq([
        "Are you a human? \e[90m(yup/Nope)\e[0m ",
        "\e[2K\e[1GAre you a human? \e[90m(yup/Nope)\e[0m Y",
        "\e[2K\e[1GAre you a human? \e[90m(yup/Nope)\e[0m Yu",
        "\e[2K\e[1GAre you a human? \e[90m(yup/Nope)\e[0m Yup",
        "\e[2K\e[1GAre you a human? \e[90m(yup/Nope)\e[0m Yup\n",
        "\e[1A\e[2K\e[1G",
        "Are you a human? \e[32myup\e[0m\n"
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
        "\e[2K\e[1GAre you a human? \e[90m(Agree/Disagree)\e[0m a",
        "\e[2K\e[1GAre you a human? \e[90m(Agree/Disagree)\e[0m ag",
        "\e[2K\e[1GAre you a human? \e[90m(Agree/Disagree)\e[0m agr",
        "\e[2K\e[1GAre you a human? \e[90m(Agree/Disagree)\e[0m agre",
        "\e[2K\e[1GAre you a human? \e[90m(Agree/Disagree)\e[0m agree",
        "\e[2K\e[1GAre you a human? \e[90m(Agree/Disagree)\e[0m agree\n",
        "\e[1A\e[2K\e[1G",
        "Are you a human? \e[32mAgree\e[0m\n"
      ].join)
    end
  end
end
