# frozen_string_literal: true

RSpec.describe TTY::Prompt do
  let(:symbols) { TTY::Prompt::Symbols.symbols }
  let(:up_down) { "#{symbols[:arrow_up]}/#{symbols[:arrow_down]}" }
  let(:left_right) { "#{symbols[:arrow_left]}/#{symbols[:arrow_right]}"}

  def output_helper(prompt, choices, active, selected, options = {})
    raise ":init requires :hint" if options[:init] && options[:hint].nil?
    hint = options[:hint]
    init = options.fetch(:init, false)
    enum = options[:enum]

    out = []
    out << "\e[?25l" if init
    out << prompt << " "
    out << "(max. #{options[:max]}) " if options[:max]
    out << selected.join(', ')
    out << " " if init && !selected.empty?
    out << "\e[90m" if init
    out << (init ? "(#{hint})\e[0m" : " (#{hint})") if hint
    out << "\n"
    out << choices.map.with_index do |choice, i|
      name = choice.is_a?(Hash) ? choice[:name] : choice
      disabled = choice.is_a?(Hash) ? choice[:disabled] : false
      num = (i + 1).to_s + enum if enum

      prefix = name == active ? "#{symbols[:marker]} " : "  "
      prefix += if disabled
                  "\e[31m#{symbols[:cross]}\e[0m #{num}#{name} #{disabled}"
                elsif selected.include?(name)
                  "\e[32m#{symbols[:radio_on]}\e[0m #{num}#{name}"
                else
                  "#{symbols[:radio_off]} #{num}#{name}"
                end
      prefix
    end.join("\n")
    out << "\e[2K\e[1G\e[1A" * choices.count
    out << "\e[2K\e[1G"
    out.join
  end

  def exit_message(prompt, choices)
    "#{prompt} \e[32m#{choices.join(', ')}\e[0m\n\e[?25h"
  end

  # Ensure a wide prompt on CI
  before { allow(TTY::Screen).to receive(:width).and_return(200) }

  it "selects nothing when return pressed immediately" do
    prompt = TTY::TestPrompt.new
    choices = %i(vodka beer wine whisky bourbon)
    prompt.input << "\r"
    prompt.input.rewind

    expect(prompt.multi_select("Select drinks?", choices)). to eq([])

    expected_output = [
      "\e[?25lSelect drinks? \e[90m(Use #{up_down} arrow keys, press Space to select and Enter to finish)\e[0m\n",
      "#{symbols[:marker]} #{symbols[:radio_off]} vodka\n",
      "  #{symbols[:radio_off]} beer\n",
      "  #{symbols[:radio_off]} wine\n",
      "  #{symbols[:radio_off]} whisky\n",
      "  #{symbols[:radio_off]} bourbon",
      "\e[2K\e[1G\e[1A" * 5, "\e[2K\e[1G",
      "Select drinks? \n\e[?25h"
    ].join
    expect(prompt.output.string).to eq(expected_output)
  end

  it "selects item when space pressed" do
    prompt = TTY::TestPrompt.new
    choices = %w(vodka beer wine whisky bourbon)
    prompt.input << " \r"
    prompt.input.rewind
    expect(prompt.multi_select("Select drinks?", choices)). to eq(['vodka'])

    expected_output = [
      "\e[?25lSelect drinks? \e[90m(Use #{up_down} arrow keys, press Space to select and Enter to finish)\e[0m\n",
      "#{symbols[:marker]} #{symbols[:radio_off]} vodka\n",
      "  #{symbols[:radio_off]} beer\n",
      "  #{symbols[:radio_off]} wine\n",
      "  #{symbols[:radio_off]} whisky\n",
      "  #{symbols[:radio_off]} bourbon",
      "\e[2K\e[1G\e[1A" * 5, "\e[2K\e[1G",
      "Select drinks? vodka\n",
      "#{symbols[:marker]} \e[32m#{symbols[:radio_on]}\e[0m vodka\n",
      "  #{symbols[:radio_off]} beer\n",
      "  #{symbols[:radio_off]} wine\n",
      "  #{symbols[:radio_off]} whisky\n",
      "  #{symbols[:radio_off]} bourbon",
      "\e[2K\e[1G\e[1A" * 5, "\e[2K\e[1G",
      "Select drinks? \e[32mvodka\e[0m\n\e[?25h"
    ].join
    expect(prompt.output.string).to eq(expected_output)
  end

  it "selects item when space pressed but doesn't echo item if echo: false" do
    prompt = TTY::TestPrompt.new
    choices = %w(vodka beer wine whisky bourbon)
    prompt.input << " \r"
    prompt.input.rewind
    expect(prompt.multi_select("Select drinks?", choices, echo: false)). to eq(['vodka'])

    expected_output = [
      "\e[?25lSelect drinks? \e[90m(Use #{up_down} arrow keys, press Space to select and Enter to finish)\e[0m\n",
      "#{symbols[:marker]} #{symbols[:radio_off]} vodka\n",
      "  #{symbols[:radio_off]} beer\n",
      "  #{symbols[:radio_off]} wine\n",
      "  #{symbols[:radio_off]} whisky\n",
      "  #{symbols[:radio_off]} bourbon",
      "\e[2K\e[1G\e[1A" * 5, "\e[2K\e[1G",
      "Select drinks? \n",
      "#{symbols[:marker]} \e[32m#{symbols[:radio_on]}\e[0m vodka\n",
      "  #{symbols[:radio_off]} beer\n",
      "  #{symbols[:radio_off]} wine\n",
      "  #{symbols[:radio_off]} whisky\n",
      "  #{symbols[:radio_off]} bourbon",
      "\e[2K\e[1G\e[1A" * 5, "\e[2K\e[1G",
      "Select drinks? \n\e[?25h"
    ].join
    expect(prompt.output.string).to eq(expected_output)
  end

  it "sets choice custom values" do
    prompt = TTY::TestPrompt.new
    choices = {vodka: 1, beer: 2, wine: 3, whisky: 4, bourbon: 5}
    prompt.input << " \r"
    prompt.input.rewind
    expect(prompt.multi_select("Select drinks?", choices)).to eq([1])
    expected_output = [
      "\e[?25lSelect drinks? \e[90m(Use #{up_down} arrow keys, press Space to select and Enter to finish)\e[0m\n",
      "#{symbols[:marker]} #{symbols[:radio_off]} vodka\n",
      "  #{symbols[:radio_off]} beer\n",
      "  #{symbols[:radio_off]} wine\n",
      "  #{symbols[:radio_off]} whisky\n",
      "  #{symbols[:radio_off]} bourbon",
      "\e[2K\e[1G\e[1A" * 5, "\e[2K\e[1G",
      "Select drinks? vodka\n",
      "#{symbols[:marker]} \e[32m#{symbols[:radio_on]}\e[0m vodka\n",
      "  #{symbols[:radio_off]} beer\n",
      "  #{symbols[:radio_off]} wine\n",
      "  #{symbols[:radio_off]} whisky\n",
      "  #{symbols[:radio_off]} bourbon",
      "\e[2K\e[1G\e[1A" * 5, "\e[2K\e[1G",
      "Select drinks? \e[32mvodka\e[0m\n\e[?25h"
    ].join
    expect(prompt.output.string).to eq(expected_output)
  end

  it "sets choice name and value through DSL" do
    prompt = TTY::TestPrompt.new
    prompt.input << " \r"
    prompt.input.rewind
    value = prompt.multi_select("Select drinks?") do |menu|
              menu.symbols marker: '>', radio_off: '-', radio_on: '='
              menu.enum ')'

              menu.choice :vodka, {score: 1}
              menu.choice :beer, 2
              menu.choice :wine, 3
              menu.choices whisky: 4, bourbon: 5
            end
    expect(value).to eq([{score: 1}])
    expect(prompt.output.string).to eq([
      "\e[?25lSelect drinks? \e[90m(Use #{up_down} arrow or number (1-5) keys, press Space to select and Enter to finish)\e[0m\n",
      "> - 1) vodka\n",
      "  - 2) beer\n",
      "  - 3) wine\n",
      "  - 4) whisky\n",
      "  - 5) bourbon",
      "\e[2K\e[1G\e[1A" * 5, "\e[2K\e[1G",
      "Select drinks? vodka\n",
      "> \e[32m=\e[0m 1) vodka\n",
      "  - 2) beer\n",
      "  - 3) wine\n",
      "  - 4) whisky\n",
      "  - 5) bourbon",
      "\e[2K\e[1G\e[1A" * 5, "\e[2K\e[1G",
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
      "\e[?25lSelect drinks? beer, bourbon \e[90m(Use #{up_down} arrow keys, press Space to select and Enter to finish)\e[0m\n",
      "  #{symbols[:radio_off]} vodka\n",
      "  \e[32m#{symbols[:radio_on]}\e[0m beer\n",
      "  #{symbols[:radio_off]} wine\n",
      "  #{symbols[:radio_off]} whisky\n",
      "#{symbols[:marker]} \e[32m#{symbols[:radio_on]}\e[0m bourbon",
      "\e[2K\e[1G\e[1A" * 5, "\e[2K\e[1G",
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
      "\e[?25l[?] Select drinks? \e[90m(Use #{up_down} arrow keys, press Space to select and Enter to finish)\e[0m\n",
      "#{symbols[:marker]} #{symbols[:radio_off]} vodka\n",
      "  #{symbols[:radio_off]} beer\n",
      "  #{symbols[:radio_off]} wine\n",
      "  #{symbols[:radio_off]} whisky\n",
      "  #{symbols[:radio_off]} bourbon",
      "\e[2K\e[1G\e[1A" * 5, "\e[2K\e[1G",
      "[?] Select drinks? \n\e[?25h"
    ].join)
  end

  it "changes selected item color & marker" do
    prompt = TTY::TestPrompt.new
    choices = %w(vodka beer wine whisky bourbon)
    prompt.input << "\r"
    prompt.input.rewind
    options = {default: [1], active_color: :blue, symbols: {marker: '>'}}
    expect(prompt.multi_select("Select drinks?", choices, options)). to eq(['vodka'])
    expect(prompt.output.string).to eq([
      "\e[?25lSelect drinks? vodka \e[90m(Use #{up_down} arrow keys, press Space to select and Enter to finish)\e[0m\n",
      "> \e[34m#{symbols[:radio_on]}\e[0m vodka\n",
      "  #{symbols[:radio_off]} beer\n",
      "  #{symbols[:radio_off]} wine\n",
      "  #{symbols[:radio_off]} whisky\n",
      "  #{symbols[:radio_off]} bourbon",
      "\e[2K\e[1G\e[1A" * 5, "\e[2K\e[1G",
      "Select drinks? \e[34mvodka\e[0m\n\e[?25h"
    ].join)
  end

  it "changes help text" do
    prompt = TTY::TestPrompt.new
    choices = %w(vodka beer wine whisky bourbon)
    prompt.input << "\r"
    prompt.input.rewind

    answer = prompt.multi_select("Select drinks?", choices, help: '(Bash keyboard)')

    expect(answer).to eq([])
    expected_output = [
      "\e[?25lSelect drinks? \e[90m(Bash keyboard)\e[0m\n",
      "#{symbols[:marker]} #{symbols[:radio_off]} vodka\n",
      "  #{symbols[:radio_off]} beer\n",
      "  #{symbols[:radio_off]} wine\n",
      "  #{symbols[:radio_off]} whisky\n",
      "  #{symbols[:radio_off]} bourbon",
      "\e[2K\e[1G\e[1A" * 5, "\e[2K\e[1G",
      "Select drinks? \n\e[?25h"
    ].join
    expect(prompt.output.string).to eq(expected_output)
  end

  context "when paginated" do
    it "paginates long selections" do
      prompt = TTY::TestPrompt.new
      choices = %w(A B C D E F G H)
      prompt.input << "\r"
      prompt.input.rewind

      answer = prompt.multi_select("What letter?", choices, per_page: 3, default: 4)

      expect(answer).to eq(['D'])
      expected_output = [
        "\e[?25lWhat letter? D \e[90m(Use #{up_down} and #{left_right} arrow keys, press Space to select and Enter to finish)\e[0m\n",
        "#{symbols[:marker]} \e[32m#{symbols[:radio_on]}\e[0m D\n",
        "  #{symbols[:radio_off]} E\n",
        "  #{symbols[:radio_off]} F",
        "\e[2K\e[1G\e[1A" * 3,
        "\e[2K\e[1G",
        "What letter? \e[32mD\e[0m\n\e[?25h",
      ].join
      expect(prompt.output.string).to eq(expected_output)
    end

    it "paginates choices as hash object" do
      prompt = TTY::TestPrompt.new
      choices = {A: 1, B: 2, C: 3, D: 4, E: 5, F: 6, G: 7, H: 8}
      prompt.input << "\r"
      prompt.input.rewind

      answer = prompt.multi_select("What letter?", choices, default: 4, per_page: 3)

      expect(answer).to eq([4])
      expected_output = [
        "\e[?25lWhat letter? D ",
        "\e[90m(Use #{up_down} and #{left_right} arrow keys, press Space to select and Enter to finish)\e[0m\n",
        "#{symbols[:marker]} \e[32m#{symbols[:radio_on]}\e[0m D\n",
        "  #{symbols[:radio_off]} E\n",
        "  #{symbols[:radio_off]} F",
        "\e[2K\e[1G\e[1A" * 3, "\e[2K\e[1G",
        "What letter? \e[32mD\e[0m\n\e[?25h",
      ].join
      expect(prompt.output.string).to eq(expected_output)
    end

    it "paginates long selections through DSL" do
      prompt = TTY::TestPrompt.new
      choices = %w(A B C D E F G H)
      prompt.input << "\r"
      prompt.input.rewind

      answer = prompt.multi_select("What letter?") do |menu|
                menu.per_page 3
                menu.default 4
                menu.choices choices
              end

      expect(answer).to eq(['D'])
      expected_output = [
        "\e[?25lWhat letter? D ",
        "\e[90m(Use #{up_down} and #{left_right} arrow keys, press Space to select and Enter to finish)\e[0m\n",
        "#{symbols[:marker]} \e[32m#{symbols[:radio_on]}\e[0m D\n",
        "  #{symbols[:radio_off]} E\n",
        "  #{symbols[:radio_off]} F",
        "\e[2K\e[1G\e[1A" * 3,
        "\e[2K\e[1G",
        "What letter? \e[32mD\e[0m\n\e[?25h",
      ].join
      expect(prompt.output.string).to eq(expected_output)
    end

    it "doesn't paginate short selections" do
      prompt = TTY::TestPrompt.new
      choices = %w(A B C D)
      prompt.input << "\r"
      prompt.input.rewind
      value = prompt.multi_select("What letter?", choices, per_page: 4, default: 1)
      expect(value).to eq(['A'])

      expect(prompt.output.string).to eq([
        "\e[?25lWhat letter? A ",
        "\e[90m(Use #{up_down} arrow keys, press Space to select and Enter to finish)\e[0m\n",
        "#{symbols[:marker]} \e[32m#{symbols[:radio_on]}\e[0m A\n",
        "  #{symbols[:radio_off]} B\n",
        "  #{symbols[:radio_off]} C\n",
        "  #{symbols[:radio_off]} D",
        "\e[2K\e[1G\e[1A" * 4, "\e[2K\e[1G",
        "What letter? \e[32mA\e[0m\n\e[?25h",
      ].join)
    end

    it "navigates evenly paged output with right arrow until end of selection" do
      prompt = TTY::TestPrompt.new
      choices = ('1'..'12').to_a
      prompt.on(:keypress) { |e| prompt.trigger(:keyright) if e.value == "l" }
      prompt.input << "l" << "l" << "l" << " " << "\r"
      prompt.input.rewind

      answer = prompt.multi_select("What number?", choices, per_page: 4)

      expect(answer).to eq(["9"])

      expected_output = [
        output_helper("What number?", choices[0..3], "1", [], init: true,
          hint: "Use #{up_down} and #{left_right} arrow keys, press Space to select and Enter to finish"),
        output_helper("What number?", choices[4..7], "5", []),
        output_helper("What number?", choices[8..11], "9", []),
        output_helper("What number?", choices[8..11], "9", []),
        output_helper("What number?", choices[8..11], "9", ["9"]),
        "What number? \e[32m9\e[0m\n\e[?25h",
      ].join

      expect(prompt.output.string).to eq(expected_output)
    end

    it "navigates unevenly paged output with right arrow until the end of selection" do
      prompt = TTY::TestPrompt.new
      choices = ('1'..'10').to_a
      prompt.on(:keypress) { |e| prompt.trigger(:keyright) if e.value == "l" }
      prompt.input << "l" << "l" << "l" << " " << "\r"
      prompt.input.rewind

      answer = prompt.multi_select("What number?", choices, default: 4, per_page: 4)

      expect(answer).to eq(['4', '10'])

      expected_output = [
        output_helper("What number?", choices[3..6], "4", ["4"], init: true,
          hint: "Use #{up_down} and #{left_right} arrow keys, press Space to select and Enter to finish"),
        output_helper("What number?", choices[4..7], "8", ["4"]),
        output_helper("What number?", choices[8..9], "10", ["4"]),
        output_helper("What number?", choices[8..9], "10", ["4"]),
        output_helper("What number?", choices[8..9], "10", ["4", "10"]),
        "What number? \e[32m4, 10\e[0m\n\e[?25h",
      ].join

      expect(prompt.output.string).to eq(expected_output)
    end

    it "navigates left and right" do
      prompt = TTY::TestPrompt.new
      choices = ('1'..'10').to_a
      prompt.on(:keypress) { |e|
        prompt.trigger(:keyright) if e.value == "l"
        prompt.trigger(:keyleft) if e.value == "h"
      }
      prompt.input << "l" << "l" << "h" << " " << "\r"
      prompt.input.rewind

      answer = prompt.multi_select("What number?", choices, default: 2, per_page: 4)

      expect(answer).to eq(['2', '6'])

      expected_output = [
        output_helper("What number?", choices[0..3], "2", ["2"], init: true,
          hint: "Use #{up_down} and #{left_right} arrow keys, press Space to select and Enter to finish"),
        output_helper("What number?", choices[4..7], "6", ["2"]),
        output_helper("What number?", choices[8..9], "10", ["2"]),
        output_helper("What number?", choices[4..7], "6", ["2"]),
        output_helper("What number?", choices[4..7], "6", ["2", "6"]),
        "What number? \e[32m2, 6\e[0m\n\e[?25h",
      ].join

      expect(prompt.output.string).to eq(expected_output)
    end

    it "combines up/down navigation with left/right" do
      prompt = TTY::TestPrompt.new
      choices = ('1'..'11').to_a
      prompt.on(:keypress) { |e|
        prompt.trigger(:keyup)    if e.value == "k"
        prompt.trigger(:keydown)  if e.value == "j"
        prompt.trigger(:keyright) if e.value == "l"
        prompt.trigger(:keyleft)  if e.value == "h"
      }
      prompt.input << "j" << "l" << "k" << "k" << "h" << " " << "\r"
      prompt.input.rewind

      answer = prompt.multi_select("What number?", choices, default: 2, per_page: 4)

      expect(answer).to eq(['2', '1'])

      expected_output = [
        output_helper("What number?", choices[0..3], "2", ["2"], init: true,
          hint: "Use #{up_down} and #{left_right} arrow keys, press Space to select and Enter to finish"),
        output_helper("What number?", choices[0..3], "3", ["2"]),
        output_helper("What number?", choices[4..7], "7", ["2"]),
        output_helper("What number?", choices[4..7], "6", ["2"]),
        output_helper("What number?", choices[3..6], "5", ["2"]),
        output_helper("What number?", choices[0..3], "1", ["2"]),
        output_helper("What number?", choices[0..3], "1", ["2", "1"]),
        "What number? \e[32m2, 1\e[0m\n\e[?25h",
      ].join

      expect(prompt.output.string).to eq(expected_output)
    end
  end

  context "with :cycle" do
    it "doesn't cycle by default" do
      prompt = TTY::TestPrompt.new
      choices = %w(A B C)
      prompt.on(:keypress) { |e| prompt.trigger(:keydown) if e.value == "j" }
      prompt.input << "j" << "j" << "j" << " " << "\r"
      prompt.input.rewind

      value = prompt.multi_select("What letter?", choices)
      expect(value).to eq(["C"])

      expect(prompt.output.string).to eq(
        output_helper("What letter?", choices, "A", [], init: true,
          hint: "Use #{up_down} arrow keys, press Space to select and Enter to finish") +
        output_helper("What letter?", choices, "B", []) +
        output_helper("What letter?", choices, "C", []) +
        output_helper("What letter?", choices, "C", []) +
        output_helper("What letter?", choices, "C", ["C"]) +
        "What letter? \e[32mC\e[0m\n\e[?25h"
      )
    end

    it "cycles when configured to do so" do
      prompt = TTY::TestPrompt.new
      choices = %w(A B C)
      prompt.on(:keypress) { |e| prompt.trigger(:keydown) if e.value == "j" }
      prompt.input << "j" << "j" << "j" << " " << "\r"
      prompt.input.rewind

      value = prompt.multi_select("What letter?", choices, cycle: true)

      expect(value).to eq(["A"])
      expect(prompt.output.string).to eq(
        output_helper("What letter?", choices, "A", [], init: true,
          hint: "Use #{up_down} arrow keys, press Space to select and Enter to finish") +
        output_helper("What letter?", choices, "B", []) +
        output_helper("What letter?", choices, "C", []) +
        output_helper("What letter?", choices, "A", []) +
        output_helper("What letter?", choices, "A", ["A"]) +
        "What letter? \e[32mA\e[0m\n\e[?25h"
      )
    end

    it "cycles choices using left/right arrows" do
      prompt = TTY::TestPrompt.new
      choices = ('1'..'10').to_a
      prompt.on(:keypress) { |e|
        prompt.trigger(:keyright) if e.value == "l"
        prompt.trigger(:keyleft) if e.value == "h"
      }
      prompt.input << "l" << "l" << "l" << "h" << " " << "\r"
      prompt.input.rewind

      answer = prompt.multi_select("What number?", choices, default: 2, per_page: 4, cycle: true)

      expect(answer).to eq(['2', '10'])

      expected_output = [
        "\e[?25lWhat number? 2 ",
        "\e[90m(Use #{up_down} and #{left_right} arrow keys, press Space to select and Enter to finish)\e[0m\n",
        "  #{symbols[:radio_off]} 1\n",
        "#{symbols[:marker]} \e[32m#{symbols[:radio_on]}\e[0m 2\n",
        "  #{symbols[:radio_off]} 3\n",
        "  #{symbols[:radio_off]} 4",
        "\e[2K\e[1G\e[1A" * 4,
        "\e[2K\e[1G",
        "What number? 2\n",
        "  #{symbols[:radio_off]} 5\n",
        "#{symbols[:marker]} #{symbols[:radio_off]} 6\n",
        "  #{symbols[:radio_off]} 7\n",
        "  #{symbols[:radio_off]} 8",
        "\e[2K\e[1G\e[1A" * 4,
        "\e[2K\e[1G",
        "What number? 2\n",
        "  #{symbols[:radio_off]} 9\n",
        "#{symbols[:marker]} #{symbols[:radio_off]} 10",
        "\e[2K\e[1G\e[1A" * 2,
        "\e[2K\e[1G",
        "What number? 2\n",
        "  #{symbols[:radio_off]} 1\n",
        "#{symbols[:marker]} \e[32m#{symbols[:radio_on]}\e[0m 2\n",
        "  #{symbols[:radio_off]} 3\n",
        "  #{symbols[:radio_off]} 4",
        "\e[2K\e[1G\e[1A" * 4,
        "\e[2K\e[1G",
        "What number? 2\n",
        "  #{symbols[:radio_off]} 9\n",
        "#{symbols[:marker]} #{symbols[:radio_off]} 10",
        "\e[2K\e[1G\e[1A" * 2,
        "\e[2K\e[1G",
        "What number? 2, 10\n",
        "  #{symbols[:radio_off]} 9\n",
        "#{symbols[:marker]} \e[32m#{symbols[:radio_on]}\e[0m 10",
        "\e[2K\e[1G\e[1A" * 2,
        "\e[2K\e[1G",
        "What number? \e[32m2, 10\e[0m\n\e[?25h",
      ].join

      expect(prompt.output.string).to eq(expected_output)
    end
  end

  context "with filter" do
    it "doesn't lose the selection when switching between filters" do
      prompt = TTY::TestPrompt.new
      prompt.on(:keypress) { |e| prompt.trigger(:keydelete) if e.value == "\r" }
      prompt.input << " "         # select `Tiny`
      prompt.input << "a" << " "  # match and select `Large`
      prompt.input << "\u007F"    # backspace (shows all)
      prompt.input << "\r"
      prompt.input.rewind

      answer = prompt.multi_select("What size?", %w(Tiny Medium Large Huge), filter: true)
      expect(answer).to eql(%w(Tiny Large))

      expected_prompt_output =
        output_helper("What size?", %w(Tiny Medium Large Huge), "Tiny", %w(), init: true,
          hint: "Use #{up_down} arrow keys, press Space to select and Enter to finish, and letter keys to filter") +
        output_helper("What size?", %w(Tiny Medium Large Huge), "Tiny", %w(Tiny)) +
        output_helper("What size?", %w(Large), "Large", %w(Tiny), hint: 'Filter: "a"') +
        output_helper("What size?", %w(Large), "Large", %w(Tiny Large), hint: 'Filter: "a"') +
        output_helper("What size?", %w(Tiny Medium Large Huge), "Tiny", %w(Tiny Large)) +
        exit_message("What size?", %w(Tiny Large))

      expect(prompt.output.string).to eql(expected_prompt_output)
    end
  end

  context "with :disabled" do
    it "fails when default item is also disabled" do
      prompt = TTY::TestPrompt.new
      choices = [
        {name: 'vodka', disabled: true},
        'beer', 'wine', 'whisky', 'bourbon'
      ]
      expect {
        prompt.multi_select("Select drinks?", choices, default: 1)
      }.to raise_error(TTY::Prompt::ConfigurationError,
        /default index `1` matches disabled choice item/)
    end

    it "adjusts active index to match first non-disabled choice" do
      choices = [
        {name: 'vodka', disabled: true},
        'beer', 'wine', 'whisky', 'bourbon'
      ]
      prompt = TTY::TestPrompt.new
      prompt.input << " " << "\r"
      prompt.input.rewind

      answer = prompt.multi_select("Select drinks?", choices)
      expect(answer).to eq(['beer'])
    end

    it "omits disabled choice when nagivating menu" do
      choices = [
        {name: 'A'},
        {name: 'B', disabled: '(out)'},
        {name: 'C', disabled: '(out)'},
        {name: 'D'},
        {name: 'E'}
      ]
      prompt = TTY::TestPrompt.new
      prompt.on(:keypress) { |e| prompt.trigger(:keydown) if e.value == "j" }
      prompt.input << "j" << " " << "j" << " " << "\r"
      prompt.input.rewind

      answer = prompt.multi_select("What letter?", choices)
      expect(answer).to eq(%w[D E])

      expected_output =
        output_helper("What letter?", choices, "A", [], init: true,
          hint: "Use #{up_down} arrow keys, press Space to select and Enter to finish") +
        output_helper("What letter?", choices, "D", []) +
        output_helper("What letter?", choices, "D", %w[D]) +
        output_helper("What letter?", choices, "E", %w[D]) +
        output_helper("What letter?", choices, "E", %w[D E]) +
        exit_message("What letter?", %w[D E])

      expect(prompt.output.string).to eq(expected_output)
    end

    it "omits disabled choice when number key is pressed" do
      choices = [
        {name: 'vodka', value: 1},
        {name: 'beer', value: 1, disabled: true},
        {name: 'wine', value: 1},
        {name: 'whisky', value: 1, disabled: true},
        {name: 'bourbon', value: 1}
      ]
      prompt = TTY::TestPrompt.new
      prompt.input << "2" << " \r"
      prompt.input.rewind
      answer = prompt.multi_select("Select drinks?") do |menu|
                menu.enum ')'

                menu.choice :vodka, 1
                menu.choice :beer, 2, disabled: true
                menu.choice :wine, 3
                menu.choice :whisky, 4, disabled: true
                menu.choice :bourbon, 5
              end
      expect(answer).to eq([1])

      expected_output =
        output_helper("Select drinks?", choices, "vodka", [], init: true, enum: ') ',
          hint: "Use #{up_down} arrow or number (1-5) keys, press Space to select and Enter to finish") +
        output_helper("Select drinks?", choices, "vodka", [], enum: ') ') +
        output_helper("Select drinks?", choices, "vodka", %w[vodka], enum: ') ') +
        exit_message("Select drinks?", %w[vodka])

      expect(prompt.output.string).to eq(expected_output)
    end
  end

  context "with :max" do
    it "limits number of choices" do
      prompt = TTY::TestPrompt.new
      choices = %w(A B C)
      prompt.on(:keypress) { |e|
        prompt.trigger(:keyup)   if e.value == "k"
        prompt.trigger(:keydown) if e.value == "j"
      }
      prompt.input << " " << "j" << " " <<  "j" << " " << "k" << " " << "j" << " "  << "\r"
      prompt.input.rewind

      value = prompt.multi_select("What letter?", choices, max: 2, per_page: 100)
      expect(value).to eq(["A", "C"])

      expected_output =
        output_helper("What letter?", choices, "A", [], init: true, max: 2,
          hint: "Use #{up_down} arrow keys, press Space to select and Enter to finish") +
        output_helper("What letter?", choices, "A", %w[A], max: 2) +
        output_helper("What letter?", choices, "B", %w[A], max: 2) +
        output_helper("What letter?", choices, "B", %w[A B], max: 2) +
        output_helper("What letter?", choices, "C", %w[A B], max: 2) +
        output_helper("What letter?", choices, "C", %w[A B], max: 2) +
        output_helper("What letter?", choices, "B", %w[A B], max: 2) +
        output_helper("What letter?", choices, "B", %w[A], max: 2) +
        output_helper("What letter?", choices, "C", %w[A], max: 2) +
        output_helper("What letter?", choices, "C", %w[A C], max: 2) +
        exit_message("What letter?", %w[A C])

      expect(prompt.output.string).to eq(expected_output)
    end
  end
end
