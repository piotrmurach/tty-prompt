# encoding: utf-8

RSpec.describe TTY::Prompt, '#select' do

  subject(:prompt) { TTY::TestPrompt.new }

  it "selects by default first option" do
    choices = %w(Large Medium Small)
    prompt.input << "\r"
    prompt.input.rewind
    expect(prompt.select('What size?', choices)).to eq('Large')
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? \e[90m(Use arrow keys, press Enter to select)\e[0m\n",
      "\e[32m‣ Large\e[0m\n",
      "  Medium\n",
      "  Small",
      "\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K",
      "What size? \e[32mLarge\e[0m\n\e[?25h"
    ].join)
  end

  it "sets choice name and value" do
    choices = {large: 1, medium: 2, small: 3}
    prompt.input << " "
    prompt.input.rewind
    expect(prompt.select('What size?', choices)).to eq(1)
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? \e[90m(Use arrow keys, press Enter to select)\e[0m\n",
      "\e[32m‣ large\e[0m\n",
      "  medium\n",
      "  small",
      "\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K",
      "What size? \e[32mlarge\e[0m\n\e[?25h"
    ].join)
  end

  it "sets choice name through DSL" do
    prompt.input << " "
    prompt.input.rewind
    value = prompt.select('What size?') do |menu|
              menu.choice "Large"
              menu.choice "Medium"
              menu.choice "Small"
            end
    expect(value).to eq('Large')
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? \e[90m(Use arrow keys, press Enter to select)\e[0m\n",
      "\e[32m‣ Large\e[0m\n",
      "  Medium\n",
      "  Small",
      "\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K",
      "What size? \e[32mLarge\e[0m\n\e[?25h"
    ].join)
  end

  it "sets choice name & value through DSL" do
    prompt.input << " "
    prompt.input.rewind
    value = prompt.select('What size?') do |menu|
              menu.choice :large, 1
              menu.choice :medium, 2
              menu.choice :small, 3
            end
    expect(value).to eq(1)
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? \e[90m(Use arrow keys, press Enter to select)\e[0m\n",
      "\e[32m‣ large\e[0m\n",
      "  medium\n",
      "  small",
      "\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K",
      "What size? \e[32mlarge\e[0m\n\e[?25h"
    ].join)
  end

  it "sets choices and single choice through DSL" do
    prompt.input << " "
    prompt.input.rewind
    value = prompt.select('What size?') do |menu|
              menu.choice 'Large'
              menu.choices %w(Medium Small)
            end
    expect(value).to eq('Large')
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? \e[90m(Use arrow keys, press Enter to select)\e[0m\n",
      "\e[32m‣ Large\e[0m\n",
      "  Medium\n",
      "  Small",
      "\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K",
      "What size? \e[32mLarge\e[0m\n\e[?25h"
    ].join)
  end

  it "sets choice name & value through DSL" do
    prompt.input << " "
    prompt.input.rewind
    value = prompt.select('What size?') do |menu|
              menu.default 2
              menu.enum '.'

              menu.choice :large, 1
              menu.choice :medium, 2
              menu.choice :small, 3
            end
    expect(value).to eq(2)
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? \e[90m(Use arrow or number (0-9) keys, press Enter to select)\e[0m\n",
      "  1. large\n",
      "\e[32m‣ 2. medium\e[0m\n",
      "  3. small",
      "\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K",
      "What size? \e[32mmedium\e[0m\n\e[?25h"
    ].join)
  end

  it "sets choice value to proc and executes it" do
    prompt.input << " "
    prompt.input.rewind
    value = prompt.select('What size?', default: 2, enum: ')') do |menu|
              menu.choice :large, 1
              menu.choice :medium do 'Good choice!' end
              menu.choice :small, 3
            end
    expect(value).to eq('Good choice!')
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? \e[90m(Use arrow or number (0-9) keys, press Enter to select)\e[0m\n",
      "  1) large\n",
      "\e[32m‣ 2) medium\e[0m\n",
      "  3) small",
      "\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K",
      "What size? \e[32mmedium\e[0m\n\e[?25h"
    ].join)
  end

  it "sets default option through hash syntax" do
    choices = %w(Large Medium Small)
    prompt.input << " "
    prompt.input.rewind
    expect(prompt.select('What size?', choices, default: 2, enum: '.')).to eq('Medium')
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? \e[90m(Use arrow or number (0-9) keys, press Enter to select)\e[0m\n",
      "  1. Large\n",
      "\e[32m‣ 2. Medium\e[0m\n",
      "  3. Small",
      "\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K",
      "What size? \e[32mMedium\e[0m\n\e[?25h"
    ].join)
  end

  it "changes selected item color & marker" do
    choices = %w(Large Medium Small)
    prompt.input << " "
    prompt.input.rewind
    value = prompt.select('What size?', choices, color: :blue, marker: '>')
    expect(value).to eq('Large')
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? \e[90m(Use arrow keys, press Enter to select)\e[0m\n",
      "\e[34m> Large\e[0m\n",
      "  Medium\n",
      "  Small",
      "\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K",
      "What size? \e[34mLarge\e[0m\n\e[?25h"
    ].join)
  end

  it "changes help text" do
    choices = %w(Large Medium Small)
    prompt.input << " "
    prompt.input.rewind
    value = prompt.select('What size?', choices, help: "(Bash keyboard)")
    expect(value).to eq('Large')
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? \e[90m(Bash keyboard)\e[0m\n",
      "\e[32m‣ Large\e[0m\n",
      "  Medium\n",
      "  Small",
      "\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K",
      "What size? \e[32mLarge\e[0m\n\e[?25h"
    ].join)
  end

  it "sets prompt prefix" do
    prompt = TTY::TestPrompt.new(prefix: '[?] ')
    choices = %w(Large Medium Small)
    prompt.input << "\r"
    prompt.input.rewind
    expect(prompt.select('What size?', choices)).to eq('Large')
    expect(prompt.output.string).to eq([
      "\e[?25l[?] What size? \e[90m(Use arrow keys, press Enter to select)\e[0m\n",
      "\e[32m‣ Large\e[0m\n",
      "  Medium\n",
      "  Small",
      "\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K",
      "[?] What size? \e[32mLarge\e[0m\n\e[?25h"
    ].join)
  end

  it "verifies default index format" do
    prompt = TTY::TestPrompt.new
    choices = %w(Large Medium Small)
    prompt.input << "\r"
    prompt.input.rewind

    expect {
      prompt.select('What size?', choices, default: '')
    }.to raise_error(TTY::Prompt::ConfigurationError, /in range \(1 - 3\)/)
  end

  it "verifies default index range" do
    prompt = TTY::TestPrompt.new
    choices = %w(Large Medium Small)
    prompt.input << "\r"
    prompt.input.rewind

    expect {
      prompt.select('What size?', choices, default: 10)
    }.to raise_error(TTY::Prompt::ConfigurationError, /`10` out of range \(1 - 3\)/)
  end
end
