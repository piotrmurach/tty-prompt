# encoding: utf-8

require 'spec_helper'

RSpec.describe TTY::Prompt do
  let(:color) { Pastel.new(enabled: true) }

  before { allow(Pastel).to receive(:new).and_return(color) }

  it "selects nothing when return pressed immediately" do
    prompt = TTY::TestPrompt.new
    choices = %w(vodka beer wine whisky bourbon)
    prompt.input << "\r"
    prompt.input.rewind
    expect(prompt.multi_select("Select drinks?", choices)). to eq([])
    expect(prompt.output.string).to eq([
      "\e[?25lSelect drinks? \e[90m(Use arrow keys, press Space to select and Enter to finish)\e[0m\n",
      "‣ ⬡ vodka\n",
      "  ⬡ beer\n",
      "  ⬡ wine\n",
      "  ⬡ whisky\n",
      "  ⬡ bourbon\n",
      "\e[1A\e[1000D\e[K" * 6,
      "Select drinks? \n\e[?25h"
    ].join)
  end

  it "selects item when space pressed" do
    prompt = TTY::TestPrompt.new
    choices = %w(vodka beer wine whisky bourbon)
    prompt.input << " \r"
    prompt.input.rewind
    expect(prompt.multi_select("Select drinks?", choices)). to eq(['vodka'])
    expect(prompt.output.string).to eq([
      "\e[?25lSelect drinks? \e[90m(Use arrow keys, press Space to select and Enter to finish)\e[0m\n",
      "‣ ⬡ vodka\n",
      "  ⬡ beer\n",
      "  ⬡ wine\n",
      "  ⬡ whisky\n",
      "  ⬡ bourbon\n",
      "\e[1A\e[1000D\e[K" * 6,
      "Select drinks? vodka\n",
      "‣ \e[32m⬢\e[0m vodka\n",
      "  ⬡ beer\n",
      "  ⬡ wine\n",
      "  ⬡ whisky\n",
      "  ⬡ bourbon\n",
      "\e[1A\e[1000D\e[K" * 6,
      "Select drinks? \e[32mvodka\e[0m\n\e[?25h"
    ].join)
  end

  it "sets choice custom values" do
    prompt = TTY::TestPrompt.new
    choices = {vodka: 1, beer: 2, wine: 3, whisky: 4, bourbon: 5}
    prompt.input << " \r"
    prompt.input.rewind
    expect(prompt.multi_select("Select drinks?", choices)).to eq([1])
    expect(prompt.output.string).to eq([
      "\e[?25lSelect drinks? \e[90m(Use arrow keys, press Space to select and Enter to finish)\e[0m\n",
      "‣ ⬡ vodka\n",
      "  ⬡ beer\n",
      "  ⬡ wine\n",
      "  ⬡ whisky\n",
      "  ⬡ bourbon\n",
      "\e[1A\e[1000D\e[K" * 6,
      "Select drinks? vodka\n",
      "‣ \e[32m⬢\e[0m vodka\n",
      "  ⬡ beer\n",
      "  ⬡ wine\n",
      "  ⬡ whisky\n",
      "  ⬡ bourbon\n",
      "\e[1A\e[1000D\e[K" * 6,
      "Select drinks? \e[32mvodka\e[0m\n\e[?25h"
    ].join)
  end

  it "sets choice name and value through DSL" do
    prompt = TTY::TestPrompt.new
    prompt.input << " \r"
    prompt.input.rewind
    value = prompt.multi_select("Select drinks?") do |menu|
              menu.choice :vodka, {score: 1}
              menu.choice :beer, 2
              menu.choice :wine, 3
              menu.choices whisky: 4, bourbon: 5
            end
    expect(value).to eq([{score: 1}])
    expect(prompt.output.string).to eq([
      "\e[?25lSelect drinks? \e[90m(Use arrow keys, press Space to select and Enter to finish)\e[0m\n",
      "‣ ⬡ vodka\n",
      "  ⬡ beer\n",
      "  ⬡ wine\n",
      "  ⬡ whisky\n",
      "  ⬡ bourbon\n",
      "\e[1A\e[1000D\e[K" * 6,
      "Select drinks? vodka\n",
      "‣ \e[32m⬢\e[0m vodka\n",
      "  ⬡ beer\n",
      "  ⬡ wine\n",
      "  ⬡ whisky\n",
      "  ⬡ bourbon\n",
      "\e[1A\e[1000D\e[K" * 6,
      "Select drinks? \e[32mvodka\e[0m\n\e[?25h"
    ].join)
  end

  it "sets default options through DSL syntax" do
    prompt = TTY::TestPrompt.new
    prompt.input << "\r"
    prompt.input.rewind
    value = prompt.multi_select("Select drinks?") do |menu|
              menu.default 2, 5

              menu.choice :vodka,   {score: 10}
              menu.choice :beer,    {score: 20}
              menu.choice :wine,    {score: 30}
              menu.choice :whisky,  {score: 40}
              menu.choice :bourbon, {score: 50}
            end
    expect(value).to match_array([{score: 20}, {score: 50}])
    expect(prompt.output.string).to eq([
      "\e[?25lSelect drinks? beer, bourbon\n",
      "  ⬡ vodka\n",
      "  \e[32m⬢\e[0m beer\n",
      "  ⬡ wine\n",
      "  ⬡ whisky\n",
      "‣ \e[32m⬢\e[0m bourbon\n",
      "\e[1A\e[1000D\e[K" * 6,
      "Select drinks? \e[32mbeer, bourbon\e[0m\n\e[?25h",
    ].join)
  end

  it "sets default options through hash syntax" do
    prompt = TTY::TestPrompt.new
    prompt.input << "\r"
    prompt.input.rewind
    value = prompt.multi_select("Select drinks?",default: [2, 5]) do |menu|
              menu.choice :vodka,   {score: 10}
              menu.choice :beer,    {score: 20}
              menu.choice :wine,    {score: 30}
              menu.choice :whisky,  {score: 40}
              menu.choice :bourbon, {score: 50}
            end
    expect(value).to match_array([{score: 20}, {score: 50}])
  end

  it "raises error for defaults out of range" do
    prompt = TTY::TestPrompt.new
    prompt.input << "\r"
    prompt.input.rewind
    expect {
      prompt.multi_select("Select drinks?",default: [2, 6]) do |menu|
        menu.choice :vodka,   {score: 10}
        menu.choice :beer,    {score: 20}
        menu.choice :wine,    {score: 30}
        menu.choice :whisky,  {score: 40}
        menu.choice :bourbon, {score: 50}
      end
    }.to raise_error(TTY::PromptConfigurationError,
                     /default index `6` out of range \(1 - 5\)/)
  end

  it "sets prompt prefix" do
    prompt = TTY::TestPrompt.new(prefix: '[?] ')
    choices = %w(vodka beer wine whisky bourbon)
    prompt.input << "\r"
    prompt.input.rewind
    expect(prompt.multi_select("Select drinks?", choices)). to eq([])
    expect(prompt.output.string).to eq([
      "\e[?25l[?] Select drinks? \e[90m(Use arrow keys, press Space to select and Enter to finish)\e[0m\n",
      "‣ ⬡ vodka\n",
      "  ⬡ beer\n",
      "  ⬡ wine\n",
      "  ⬡ whisky\n",
      "  ⬡ bourbon\n",
      "\e[1A\e[1000D\e[K" * 6,
      "[?] Select drinks? \n\e[?25h"
    ].join)
  end
end
