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
      "\e[?25lSelect drinks? \e[97m(Use arrow keys, press Space to select and Enter to finish)\e[0m\n",
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
      "\e[?25lSelect drinks? \e[97m(Use arrow keys, press Space to select and Enter to finish)\e[0m\n",
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
end
