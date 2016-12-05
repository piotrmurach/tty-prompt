# encoding: utf-8

RSpec.describe TTY::Prompt do
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
      "  ⬡ bourbon",
      "\e[1000D\e[K\e[1A" * 5, "\e[1000D\e[K",
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
      "  ⬡ bourbon",
      "\e[1000D\e[K\e[1A" * 5, "\e[1000D\e[K",
      "Select drinks? vodka\n",
      "‣ \e[32m⬢\e[0m vodka\n",
      "  ⬡ beer\n",
      "  ⬡ wine\n",
      "  ⬡ whisky\n",
      "  ⬡ bourbon",
      "\e[1000D\e[K\e[1A" * 5, "\e[1000D\e[K",
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
      "  ⬡ bourbon",
      "\e[1000D\e[K\e[1A" * 5, "\e[1000D\e[K",
      "Select drinks? vodka\n",
      "‣ \e[32m⬢\e[0m vodka\n",
      "  ⬡ beer\n",
      "  ⬡ wine\n",
      "  ⬡ whisky\n",
      "  ⬡ bourbon",
      "\e[1000D\e[K\e[1A" * 5, "\e[1000D\e[K",
      "Select drinks? \e[32mvodka\e[0m\n\e[?25h"
    ].join)
  end

  it "sets choice name and value through DSL" do
    prompt = TTY::TestPrompt.new
    prompt.input << " \r"
    prompt.input.rewind
    value = prompt.multi_select("Select drinks?") do |menu|
              menu.enum ')'

              menu.choice :vodka, {score: 1}
              menu.choice :beer, 2
              menu.choice :wine, 3
              menu.choices whisky: 4, bourbon: 5
            end
    expect(value).to eq([{score: 1}])
    expect(prompt.output.string).to eq([
      "\e[?25lSelect drinks? \e[90m(Use arrow or number (1-5) keys, press Space to select and Enter to finish)\e[0m\n",
      "‣ ⬡ 1) vodka\n",
      "  ⬡ 2) beer\n",
      "  ⬡ 3) wine\n",
      "  ⬡ 4) whisky\n",
      "  ⬡ 5) bourbon",
      "\e[1000D\e[K\e[1A" * 5, "\e[1000D\e[K",
      "Select drinks? vodka\n",
      "‣ \e[32m⬢\e[0m 1) vodka\n",
      "  ⬡ 2) beer\n",
      "  ⬡ 3) wine\n",
      "  ⬡ 4) whisky\n",
      "  ⬡ 5) bourbon",
      "\e[1000D\e[K\e[1A" * 5, "\e[1000D\e[K",
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
      "\e[?25lSelect drinks? beer, bourbon \e[90m(Use arrow keys, press Space to select and Enter to finish)\e[0m\n",
      "  ⬡ vodka\n",
      "  \e[32m⬢\e[0m beer\n",
      "  ⬡ wine\n",
      "  ⬡ whisky\n",
      "‣ \e[32m⬢\e[0m bourbon",
      "\e[1000D\e[K\e[1A" * 5, "\e[1000D\e[K",
      "Select drinks? \e[32mbeer, bourbon\e[0m\n\e[?25h",
    ].join)
  end

  it "sets default options through hash syntax" do
    prompt = TTY::TestPrompt.new
    prompt.input << "\r"
    prompt.input.rewind
    value = prompt.multi_select("Select drinks?", default: [2, 5]) do |menu|
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
      prompt.multi_select("Select drinks?", default: [2, 6]) do |menu|
        menu.choice :vodka,   {score: 10}
        menu.choice :beer,    {score: 20}
        menu.choice :wine,    {score: 30}
        menu.choice :whisky,  {score: 40}
        menu.choice :bourbon, {score: 50}
      end
    }.to raise_error(TTY::Prompt::ConfigurationError,
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
      "  ⬡ bourbon",
      "\e[1000D\e[K\e[1A" * 5, "\e[1000D\e[K",
      "[?] Select drinks? \n\e[?25h"
    ].join)
  end

  it "changes selected item color & marker" do
    prompt = TTY::TestPrompt.new
    choices = %w(vodka beer wine whisky bourbon)
    prompt.input << "\r"
    prompt.input.rewind
    options = {default: [1], active_color: :blue, marker: '>'}
    expect(prompt.multi_select("Select drinks?", choices, options)). to eq(['vodka'])
    expect(prompt.output.string).to eq([
      "\e[?25lSelect drinks? vodka \e[90m(Use arrow keys, press Space to select and Enter to finish)\e[0m\n",
      "> \e[34m⬢\e[0m vodka\n",
      "  ⬡ beer\n",
      "  ⬡ wine\n",
      "  ⬡ whisky\n",
      "  ⬡ bourbon",
      "\e[1000D\e[K\e[1A" * 5, "\e[1000D\e[K",
      "Select drinks? \e[34mvodka\e[0m\n\e[?25h"
    ].join)
  end

  it "changes help text" do
    prompt = TTY::TestPrompt.new
    choices = %w(vodka beer wine whisky bourbon)
    prompt.input << "\r"
    prompt.input.rewind
    expect(prompt.multi_select("Select drinks?", choices, help: '(Bash keyboard)')). to eq([])
    expect(prompt.output.string).to eq([
      "\e[?25lSelect drinks? \e[90m(Bash keyboard)\e[0m\n",
      "‣ ⬡ vodka\n",
      "  ⬡ beer\n",
      "  ⬡ wine\n",
      "  ⬡ whisky\n",
      "  ⬡ bourbon",
      "\e[1000D\e[K\e[1A" * 5, "\e[1000D\e[K",
      "Select drinks? \n\e[?25h"
    ].join)
  end

  it "paginates long selections" do
    prompt = TTY::TestPrompt.new
    choices = %w(A B C D E F G H)
    prompt.input << "\r"
    prompt.input.rewind
    value = prompt.multi_select("What letter?", choices, per_page: 3, default: 4)
    expect(value).to eq(['D'])
    expect(prompt.output.string).to eq([
      "\e[?25lWhat letter? D \e[90m(Use arrow keys, press Space to select and Enter to finish)\e[0m\n",
      "‣ \e[32m⬢\e[0m D\n",
      "  ⬡ E\n",
      "  ⬡ F",
      "\e[1000D\e[K\e[1A" * 3 + "\e[1000D\e[K",
      "What letter? \e[32mD\e[0m\n\e[?25h",
    ].join)
  end
end
