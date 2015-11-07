# encoding: utf-8

require 'spec_helper'

RSpec.describe TTY::Prompt, '#select' do
  it "selects by default first option" do
    prompt = TTY::TestPrompt.new
    choices = %w(Large Medium Small)
    prompt.input << " "
    prompt.input.rewind
    prompt.select('What size?', choices)
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? (Use arrow keys, press Enter to select)\n",
      "\e[32m‣ Large\e[0m\n",
      "  Medium\n",
      "  Small\n",
      "\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K",
      "\e[?25hWhat size?\n",
      "\e[32mLarge\e[0m\n"
    ].join)
  end

  it "allows to set choice name and value" do
    prompt = TTY::TestPrompt.new
    choices = {large: 1, medium: 2, small: 3}
    prompt.input << " "
    prompt.input.rewind
    prompt.select('What size?', choices)
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? (Use arrow keys, press Enter to select)\n",
      "\e[32m‣ large\e[0m\n",
      "  medium\n",
      "  small\n",
      "\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K",
      "\e[?25hWhat size?\n",
      "\e[32m1\e[0m\n"
    ].join)
  end

  it "allows to set choice name through DSL" do
    prompt = TTY::TestPrompt.new
    prompt.input << " "
    prompt.input.rewind
    prompt.select('What size?') do |menu|
      menu.choice "Large"
      menu.choice "Medium"
      menu.choice "Small"
    end
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? (Use arrow keys, press Enter to select)\n",
      "\e[32m‣ Large\e[0m\n",
      "  Medium\n",
      "  Small\n",
      "\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K",
      "\e[?25hWhat size?\n",
      "\e[32mLarge\e[0m\n"
    ].join)
  end

  it "allows to set choice name & value through DSL" do
    prompt = TTY::TestPrompt.new
    prompt.input << " "
    prompt.input.rewind
    prompt.select('What size?') do |menu|
      menu.choice :large, 1
      menu.choice :medium, 2
      menu.choice :small, 3
    end
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? (Use arrow keys, press Enter to select)\n",
      "\e[32m‣ large\e[0m\n",
      "  medium\n",
      "  small\n",
      "\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K",
      "\e[?25hWhat size?\n",
      "\e[32m1\e[0m\n"
    ].join)
  end

  it "allows to set choices and single choice through DSL" do
    prompt = TTY::TestPrompt.new
    prompt.input << " "
    prompt.input.rewind
    prompt.select('What size?') do |menu|
      menu.choice 'Large'
      menu.choices %w(Medium Small)
    end
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? (Use arrow keys, press Enter to select)\n",
      "\e[32m‣ Large\e[0m\n",
      "  Medium\n",
      "  Small\n",
      "\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K",
      "\e[?25hWhat size?\n",
      "\e[32mLarge\e[0m\n"
    ].join)
  end

  it "allows to set choice name & value through DSL" do
    prompt = TTY::TestPrompt.new
    prompt.input << " "
    prompt.input.rewind
    prompt.select('What size?') do |menu|
      menu.default 2
      menu.choice :large, 1
      menu.choice :medium, 2
      menu.choice :small, 3
    end
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? (Use arrow keys, press Enter to select)\n",
      "  large\n",
      "\e[32m‣ medium\e[0m\n",
      "  small\n",
      "\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K",
      "\e[?25hWhat size?\n",
      "\e[32m2\e[0m\n"
    ].join)
  end

  it "allows to set choice value to proc and execute it" do
    prompt = TTY::TestPrompt.new
    prompt.input << " "
    prompt.input.rewind
    prompt.select('What size?', default: 2) do |menu|
      menu.choice :large, 1
      menu.choice :medium do 'Good choice!' end
      menu.choice :small, 3
    end
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? (Use arrow keys, press Enter to select)\n",
      "  large\n",
      "\e[32m‣ medium\e[0m\n",
      "  small\n",
      "\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K",
      "\e[?25hWhat size?\n",
      "\e[32mGood choice!\e[0m\n"
    ].join)
  end

  it "allows to set default option" do
    prompt = TTY::TestPrompt.new
    choices = %w(Large Medium Small)
    prompt.input << " "
    prompt.input.rewind
    prompt.select('What size?', choices, default: 2)
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? (Use arrow keys, press Enter to select)\n",
      "  Large\n",
      "\e[32m‣ Medium\e[0m\n",
      "  Small\n",
      "\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K",
      "\e[?25hWhat size?\n",
      "\e[32mMedium\e[0m\n"
    ].join)
  end

  it "allows to change selected item color & marker" do
    prompt = TTY::TestPrompt.new
    choices = %w(Large Medium Small)
    prompt.input << " "
    prompt.input.rewind
    prompt.select('What size?', choices, color: :blue, marker: '>')
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? (Use arrow keys, press Enter to select)\n",
      "\e[34m> Large\e[0m\n",
      "  Medium\n",
      "  Small\n",
      "\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K",
      "\e[?25hWhat size?\n",
      "\e[34mLarge\e[0m\n"
    ].join)
  end

  it "allows to change help text" do
    prompt = TTY::TestPrompt.new
    choices = %w(Large Medium Small)
    prompt.input << " "
    prompt.input.rewind
    prompt.select('What size?', choices, help: "(Bash keyboard)")
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? (Bash keyboard)\n",
      "\e[32m‣ Large\e[0m\n",
      "  Medium\n",
      "  Small\n",
      "\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K",
      "\e[?25hWhat size?\n",
      "\e[32mLarge\e[0m\n"
    ].join)
  end
end
