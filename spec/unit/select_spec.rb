# encoding: utf-8

require 'spec_helper'

RSpec.describe TTY::Prompt, '#select' do
  let(:color) { Pastel.new(enabled: true) }

  before { allow(Pastel).to receive(:new).and_return(color) }

  it "selects by default first option" do
    prompt = TTY::TestPrompt.new
    choices = %w(Large Medium Small)
    prompt.input << "\r"
    prompt.input.rewind
    expect(prompt.select('What size?', choices)).to eq('Large')
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? \e[90m(Use arrow keys, press Enter to select)\e[0m\n",
      "\e[32m‣ Large\e[0m\n",
      "  Medium\n",
      "  Small\n",
      "\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K",
      "What size? \e[32mLarge\e[0m\n\e[?25h"
    ].join)
  end

  it "sets choice name and value" do
    prompt = TTY::TestPrompt.new
    choices = {large: 1, medium: 2, small: 3}
    prompt.input << " "
    prompt.input.rewind
    expect(prompt.select('What size?', choices)).to eq(1)
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? \e[90m(Use arrow keys, press Enter to select)\e[0m\n",
      "\e[32m‣ large\e[0m\n",
      "  medium\n",
      "  small\n",
      "\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K",
      "What size? \e[32mlarge\e[0m\n\e[?25h"
    ].join)
  end

  it "sets choice name through DSL" do
    prompt = TTY::TestPrompt.new
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
      "  Small\n",
      "\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K",
      "What size? \e[32mLarge\e[0m\n\e[?25h"
    ].join)
  end

  it "sets choice name & value through DSL" do
    prompt = TTY::TestPrompt.new
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
      "  small\n",
      "\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K",
      "What size? \e[32mlarge\e[0m\n\e[?25h"
    ].join)
  end

  it "sets choices and single choice through DSL" do
    prompt = TTY::TestPrompt.new
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
      "  Small\n",
      "\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K",
      "What size? \e[32mLarge\e[0m\n\e[?25h"
    ].join)
  end

  it "sets choice name & value through DSL" do
    prompt = TTY::TestPrompt.new
    prompt.input << " "
    prompt.input.rewind
    value = prompt.select('What size?') do |menu|
              menu.default 2

              menu.choice :large, 1
              menu.choice :medium, 2
              menu.choice :small, 3
            end
    expect(value).to eq(2)
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? \e[90m(Use arrow keys, press Enter to select)\e[0m\n",
      "  large\n",
      "\e[32m‣ medium\e[0m\n",
      "  small\n",
      "\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K",
      "What size? \e[32mmedium\e[0m\n\e[?25h"
    ].join)
  end

  it "sets choice value to proc and executes it" do
    prompt = TTY::TestPrompt.new
    prompt.input << " "
    prompt.input.rewind
    value = prompt.select('What size?', default: 2) do |menu|
              menu.choice :large, 1
              menu.choice :medium do 'Good choice!' end
              menu.choice :small, 3
            end
    expect(value).to eq('Good choice!')
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? \e[90m(Use arrow keys, press Enter to select)\e[0m\n",
      "  large\n",
      "\e[32m‣ medium\e[0m\n",
      "  small\n",
      "\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K",
      "What size? \e[32mmedium\e[0m\n\e[?25h"
    ].join)
  end

  it "sets default option through hash syntax" do
    prompt = TTY::TestPrompt.new
    choices = %w(Large Medium Small)
    prompt.input << " "
    prompt.input.rewind
    expect(prompt.select('What size?', choices, default: 2)).to eq('Medium')
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? \e[90m(Use arrow keys, press Enter to select)\e[0m\n",
      "  Large\n",
      "\e[32m‣ Medium\e[0m\n",
      "  Small\n",
      "\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K",
      "What size? \e[32mMedium\e[0m\n\e[?25h"
    ].join)
  end

  it "changes selected item color & marker" do
    prompt = TTY::TestPrompt.new
    choices = %w(Large Medium Small)
    prompt.input << " "
    prompt.input.rewind
    value = prompt.select('What size?', choices, color: :blue, marker: '>')
    expect(value).to eq('Large')
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? \e[90m(Use arrow keys, press Enter to select)\e[0m\n",
      "\e[34m> Large\e[0m\n",
      "  Medium\n",
      "  Small\n",
      "\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K",
      "What size? \e[34mLarge\e[0m\n\e[?25h"
    ].join)
  end

  it "changes help text" do
    prompt = TTY::TestPrompt.new
    choices = %w(Large Medium Small)
    prompt.input << " "
    prompt.input.rewind
    value = prompt.select('What size?', choices, help: "(Bash keyboard)")
    expect(value).to eq('Large')
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? \e[90m(Bash keyboard)\e[0m\n",
      "\e[32m‣ Large\e[0m\n",
      "  Medium\n",
      "  Small\n",
      "\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K",
      "What size? \e[32mLarge\e[0m\n\e[?25h"
    ].join)
  end
end
