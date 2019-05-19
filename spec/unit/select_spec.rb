# frozen_string_literal: true

RSpec.describe TTY::Prompt, '#select' do

  subject(:prompt) { TTY::TestPrompt.new }

  let(:symbols) { TTY::Prompt::Symbols.symbols }
  let(:up_down) { "#{symbols[:arrow_up]}/#{symbols[:arrow_down]}" }
  let(:left_right) { "#{symbols[:arrow_left]}/#{symbols[:arrow_right]}"}

  def output_helper(prompt, choices, active, options = {})
    raise ":init requires :hint" if options[:init] && options[:hint].nil?
    hint = options[:hint]
    init = options.fetch(:init, false)
    enum = options[:enum]

    out = []
    out << "\e[?25l" if init
    out << prompt << " "
    out << "\e[90m(#{hint})\e[0m" if hint
    out << "\n"
    out << choices.map.with_index do |c, i|
      name = c.is_a?(Hash) ? c[:name] : c
      disabled = c.is_a?(Hash) ? c[:disabled] : false
      num = (i + 1).to_s + enum if enum
      if disabled
        "\e[31m#{symbols[:cross]}\e[0m #{num}#{name} #{disabled}"
      elsif name == active
        "\e[32m#{symbols[:marker]} #{num}#{name}\e[0m"
      else
        "  #{num}#{name}"
      end
    end.join("\n")
    out << "\e[2K\e[1G\e[1A" * choices.count
    out << "\e[2K\e[1G"
    out << "\e[1A\e[2K\e[1G" if choices.empty?
    out.join
  end

  def exit_message(prompt, choice)
    "#{prompt} \e[32m#{choice}\e[0m\n\e[?25h"
  end

  # Ensure a wide prompt on CI
  before { allow(TTY::Screen).to receive(:width).and_return(200) }

  it "selects by default first option" do
    choices = %i(Large Medium Small)
    prompt.input << "\r"
    prompt.input.rewind

    expect(prompt.select('What size?', choices)).to eq(:Large)
    expected_output = [
      "\e[?25lWhat size? \e[90m(Use #{up_down} arrow keys, press Enter to select)\e[0m\n",
      "\e[32m#{symbols[:marker]} Large\e[0m\n",
      "  Medium\n",
      "  Small",
      "\e[2K\e[1G\e[1A" * 3,
      "\e[2K\e[1G",
      "What size? \e[32mLarge\e[0m\n\e[?25h"
    ].join

    expect(prompt.output.string).to eq(expected_output)
  end

  it "allows navigation using events without errors" do
    choices = %w(Large Medium Small)
    prompt.input << "j" << "\r"
    prompt.input.rewind
    prompt.on(:keypress) do |event|
      prompt.trigger(:keydown) if event.value == "j"
    end
    expect { prompt.select('What size?', choices) }.not_to output.to_stderr
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? \e[90m(Use #{up_down} arrow keys, press Enter to select)\e[0m\n",
      "\e[32m#{symbols[:marker]} Large\e[0m\n",
      "  Medium\n",
      "  Small",
      "\e[2K\e[1G\e[1A" * 3,
      "\e[2K\e[1G",
      "What size? \n",
      "  Large\n",
      "\e[32m#{symbols[:marker]} Medium\e[0m\n",
      "  Small",
      "\e[2K\e[1G\e[1A" * 3,
      "\e[2K\e[1G",
      "What size? \e[32mMedium\e[0m\n\e[?25h"
    ].join)
  end

  it "sets choice name and value" do
    choices = {large: 1, medium: 2, small: 3}
    prompt.input << " "
    prompt.input.rewind
    expect(prompt.select('What size?', choices, default: 1)).to eq(1)
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? \e[90m(Use #{up_down} arrow keys, press Enter to select)\e[0m\n",
      "\e[32m#{symbols[:marker]} large\e[0m\n",
      "  medium\n",
      "  small",
      "\e[2K\e[1G\e[1A" * 3,
      "\e[2K\e[1G",
      "What size? \e[32mlarge\e[0m\n\e[?25h"
    ].join)
  end

  it "sets choice name through DSL" do
    prompt.input << " "
    prompt.input.rewind
    value = prompt.select('What size?') do |menu|
              menu.symbols marker: '>'

              menu.choice "Large"
              menu.choice "Medium"
              menu.choice "Small"
            end
    expect(value).to eq('Large')
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? \e[90m(Use #{up_down} arrow keys, press Enter to select)\e[0m\n",
      "\e[32m> Large\e[0m\n",
      "  Medium\n",
      "  Small",
      "\e[2K\e[1G\e[1A" * 3,
      "\e[2K\e[1G",
      "What size? \e[32mLarge\e[0m\n\e[?25h"
    ].join)
  end

  it "sets choice name & value through DSL" do
    prompt = TTY::TestPrompt.new(symbols: {marker: '>'})
    prompt.input << " "
    prompt.input.rewind
    value = prompt.select('What size?') do |menu|
              menu.choice :large, 1
              menu.choice :medium, 2
              menu.choice :small, 3
            end
    expect(value).to eq(1)
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? \e[90m(Use #{up_down} arrow keys, press Enter to select)\e[0m\n",
      "\e[32m> large\e[0m\n",
      "  medium\n",
      "  small",
      "\e[2K\e[1G\e[1A" * 3,
      "\e[2K\e[1G",
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
      "\e[?25lWhat size? \e[90m(Use #{up_down} arrow keys, press Enter to select)\e[0m\n",
      "\e[32m#{symbols[:marker]} Large\e[0m\n",
      "  Medium\n",
      "  Small",
      "\e[2K\e[1G\e[1A" * 3,
      "\e[2K\e[1G",
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
      "\e[?25lWhat size? \e[90m(Use #{up_down} arrow or number (1-3) keys, press Enter to select)\e[0m\n",
      "  1. large\n",
      "\e[32m#{symbols[:marker]} 2. medium\e[0m\n",
      "  3. small",
      "\e[2K\e[1G\e[1A" * 3,
      "\e[2K\e[1G",
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
      "\e[?25lWhat size? \e[90m(Use #{up_down} arrow or number (1-3) keys, press Enter to select)\e[0m\n",
      "  1) large\n",
      "\e[32m#{symbols[:marker]} 2) medium\e[0m\n",
      "  3) small",
      "\e[2K\e[1G\e[1A" * 3,
      "\e[2K\e[1G",
      "What size? \e[32mmedium\e[0m\n\e[?25h"
    ].join)
  end

  it "sets default option through hash syntax" do
    choices = %w(Large Medium Small)
    prompt.input << " "
    prompt.input.rewind
    expect(prompt.select('What size?', choices, default: 2, enum: '.')).to eq('Medium')
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? \e[90m(Use #{up_down} arrow or number (1-3) keys, press Enter to select)\e[0m\n",
      "  1. Large\n",
      "\e[32m#{symbols[:marker]} 2. Medium\e[0m\n",
      "  3. Small",
      "\e[2K\e[1G\e[1A" * 3,
      "\e[2K\e[1G",
      "What size? \e[32mMedium\e[0m\n\e[?25h"
    ].join)
  end

  it "changes selected item color & marker" do
    choices = %w(Large Medium Small)
    prompt = TTY::TestPrompt.new(symbols: {marker: '>'})
    prompt.input << " "
    prompt.input.rewind
    options = {active_color: :blue, help_color: :red, symbols: {marker: '>' }}

    value = prompt.select('What size?', choices, options)

    expect(value).to eq('Large')
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? \e[31m(Use #{up_down} arrow keys, press Enter to select)\e[0m\n",
      "\e[34m> Large\e[0m\n",
      "  Medium\n",
      "  Small",
      "\e[2K\e[1G\e[1A" * 3,
      "\e[2K\e[1G",
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
      "\e[32m#{symbols[:marker]} Large\e[0m\n",
      "  Medium\n",
      "  Small",
      "\e[2K\e[1G\e[1A" * 3,
      "\e[2K\e[1G",
      "What size? \e[32mLarge\e[0m\n\e[?25h"
    ].join)
  end

  it "changes help text through DSL" do
    choices = %w(Large Medium Small)
    prompt.input << " "
    prompt.input.rewind
    value = prompt.select('What size?') do |menu|
              menu.help "(Bash keyboard)"
              menu.choices choices
            end
    expect(value).to eq('Large')
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? \e[90m(Bash keyboard)\e[0m\n",
      "\e[32m#{symbols[:marker]} Large\e[0m\n",
      "  Medium\n",
      "  Small",
      "\e[2K\e[1G\e[1A" * 3,
      "\e[2K\e[1G",
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
      "\e[?25l[?] What size? \e[90m(Use #{up_down} arrow keys, press Enter to select)\e[0m\n",
      "\e[32m#{symbols[:marker]} Large\e[0m\n",
      "  Medium\n",
      "  Small",
      "\e[2K\e[1G\e[1A" * 3,
      "\e[2K\e[1G",
      "[?] What size? \e[32mLarge\e[0m\n\e[?25h"
    ].join)
  end

  context "when paginated" do
    it "paginates long selections" do
      choices = %w(A B C D E F G H)
      prompt.input << "\r"
      prompt.input.rewind

      answer = prompt.select("What letter?", choices, per_page: 3, default: 4)

      expect(answer).to eq('D')
      expected_output = [
        "\e[?25lWhat letter? \e[90m(Use #{up_down} and #{left_right} arrow keys, press Enter to select)\e[0m\n",
        "\e[32m#{symbols[:marker]} D\e[0m\n",
        "  E\n",
        "  F",
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

      answer = prompt.select("What letter?", choices, per_page: 3, default: 4)

      expect(answer).to eq(4)
      expected_output = [
        "\e[?25lWhat letter? \e[90m(Use #{up_down} and #{left_right} arrow keys, press Enter to select)\e[0m\n",
        "\e[32m#{symbols[:marker]} D\e[0m\n",
        "  E\n",
        "  F",
        "\e[2K\e[1G\e[1A" * 3,
        "\e[2K\e[1G",
        "What letter? \e[32mD\e[0m\n\e[?25h",
      ].join
      expect(prompt.output.string).to eq(expected_output)
    end

    it "paginates long selections through DSL" do
      prompt = TTY::TestPrompt.new
      choices = %w(A B C D E F G H)
      prompt.input << "\r"
      prompt.input.rewind

      answer = prompt.select("What letter?") do |menu|
                menu.per_page 3
                menu.default 4

                menu.choices choices
              end

      expect(answer).to eq('D')


      expected_output = [
        "\e[?25lWhat letter? \e[90m(Use #{up_down} and #{left_right} arrow keys, press Enter to select)\e[0m\n",
        "\e[32m#{symbols[:marker]} D\e[0m\n",
        "  E\n",
        "  F",
        "\e[2K\e[1G\e[1A" * 3,
        "\e[2K\e[1G",
        "What letter? \e[32mD\e[0m\n\e[?25h",
      ].join
      expect(prompt.output.string).to eq(expected_output)
    end

    it "navigates evenly paged output with right arrow until end of selection" do
      prompt = TTY::TestPrompt.new
      choices = ('1'..'12').to_a
      prompt.on(:keypress) { |e| prompt.trigger(:keyright) if e.value == "l" }
      prompt.input << "l" << "l" << "l" << "\r"
      prompt.input.rewind

      answer = prompt.select("What number?", choices, per_page: 4)

      expect(answer).to eq('9')

      expected_output = [
        output_helper('What number?', choices[0..3], "1", init: true,
          hint: "Use #{up_down} and #{left_right} arrow keys, press Enter to select"),
        output_helper('What number?', choices[4..7], "5"),
        output_helper('What number?', choices[8..11], "9"),
        output_helper('What number?', choices[8..11], "9"),
        "What number? \e[32m9\e[0m\n\e[?25h",
      ].join

      expect(prompt.output.string).to eq(expected_output)
    end

    it "navigates unevenly paged output with right arrow until the end of selection" do
      prompt = TTY::TestPrompt.new
      choices = ('1'..'10').to_a
      prompt.on(:keypress) { |e| prompt.trigger(:keyright) if e.value == "l" }
      prompt.input << "l" << "l" << "l" << "\r"
      prompt.input.rewind

      answer = prompt.select("What number?", choices, default: 4, per_page: 4)

      expect(answer).to eq('10')

      expected_output = [
        output_helper('What number?', choices[3..6], "4", init: true,
          hint: "Use #{up_down} and #{left_right} arrow keys, press Enter to select"),
        output_helper('What number?', choices[4..7], "8"),
        output_helper('What number?', choices[8..9], "10"),
        output_helper('What number?', choices[8..9], "10"),
        "What number? \e[32m10\e[0m\n\e[?25h",
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
      prompt.input << "l" << "l" << "h" << "\r"
      prompt.input.rewind

      answer = prompt.select("What number?", choices, default: 2, per_page: 4)

      expect(answer).to eq('6')

      expected_output = [
        output_helper('What number?', choices[0..3], "2", init: true,
          hint: "Use #{up_down} and #{left_right} arrow keys, press Enter to select"),
        output_helper('What number?', choices[4..7], "6"),
        output_helper('What number?', choices[8..9], "10"),
        output_helper('What number?', choices[4..7], "6"),
        "What number? \e[32m6\e[0m\n\e[?25h",
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
      prompt.input << "j" << "l" << "k" << "k" << "h" << "\r"
      prompt.input.rewind

      answer = prompt.select("What number?", choices, default: 2, per_page: 4)

      expect(answer).to eq('1')

      expected_output = [
        output_helper('What number?', choices[0..3], "2", init: true,
          hint: "Use #{up_down} and #{left_right} arrow keys, press Enter to select"),
        output_helper('What number?', choices[0..3], "3"),
        output_helper('What number?', choices[4..7], "7"),
        output_helper('What number?', choices[4..7], "6"),
        output_helper('What number?', choices[3..6], "5"),
        output_helper('What number?', choices[0..3], "1"),
        "What number? \e[32m1\e[0m\n\e[?25h"
      ].join

      expect(prompt.output.string).to eq(expected_output)
    end

    it "navigates pages up/down with disabled items" do
      prompt = TTY::TestPrompt.new
      prompt.on(:keypress) { |e|
        prompt.trigger(:keyup)    if e.value == "k"
        prompt.trigger(:keydown)  if e.value == "j"
      }
      choices = [
        '1',
        {name: '2', disabled: 'out'},
        '3',
        {name: '4', disabled: 'out'},
        '5',
        {name: '6', disabled: 'out'},
        {name: '7', disabled: 'out'},
        '8',
        '9',
        {name: '10', disabled: 'out'},
      ]

      prompt.input << "j" << "j" << "j" << "j" << "\r"
      prompt.input.rewind

      answer = prompt.select("What number?", choices, per_page: 4)

      expect(answer).to eq('9')

      expected_output = [
        output_helper('What number?', choices[0..3], "1", init: true,
          hint: "Use #{up_down} and #{left_right} arrow keys, press Enter to select"),
        output_helper('What number?', choices[0..3], "3"),
        output_helper('What number?', choices[2..5], "5"),
        output_helper('What number?', choices[5..8], "8"),
        output_helper('What number?', choices[6..9], "9"),
        "What number? \e[32m9\e[0m\n\e[?25h"
      ].join('')

      expect(prompt.output.string).to eq(expected_output)
    end

    it "navigates pages left/right with disabled items" do
      prompt = TTY::TestPrompt.new
      prompt.on(:keypress) { |e|
        prompt.trigger(:keyright) if e.value == "l"
        prompt.trigger(:keyleft)  if e.value == "h"
      }
      choices = [
        {name: '1', disabled: 'out'},
        '2',
        {name: '3', disabled: 'out'},
        '4',
        '5',
        {name: '6', disabled: 'out'},
        '7',
        '8',
        '9',
        {name: '10', disabled: 'out'}
      ]

      prompt.input << "l" << "l" << "l" << "h" << "h" << "h" << "\r"
      prompt.input.rewind

      answer = prompt.select("What number?", choices, per_page: 4)

      expect(answer).to eq('2')

      expected_output = [
        output_helper('What number?', choices[0..3], "2", init: true,
          hint: "Use #{up_down} and #{left_right} arrow keys, press Enter to select"),
        output_helper('What number?', choices[4..7], "7"),
        output_helper('What number?', choices[8..9], "9"),
        output_helper('What number?', choices[8..9], "9"),
        output_helper('What number?', choices[4..7], "5"),
        output_helper('What number?', choices[0..3], "2"),
        output_helper('What number?', choices[0..3], "2"),
        "What number? \e[32m2\e[0m\n\e[?25h"
      ].join('')

      expect(prompt.output.string).to eq(expected_output)
    end
  end

  context 'with :cycle option' do
    it "doesn't cycle by default" do
      prompt = TTY::TestPrompt.new
      choices = %w(A B C)
      prompt.on(:keypress) { |e| prompt.trigger(:keydown) if e.value == "j" }
      prompt.input << "j" << "j" << "j" << "\r"
      prompt.input.rewind

      value = prompt.select("What letter?", choices)

      expect(value).to eq("C")
      expected_output = [
        output_helper("What letter?", choices, "A", init: true,
          hint: "Use #{up_down} arrow keys, press Enter to select"),
        output_helper("What letter?", choices, "B"),
        output_helper("What letter?", choices, "C"),
        output_helper("What letter?", choices, "C"),
        "What letter? \e[32mC\e[0m\n\e[?25h"
      ].join
      expect(prompt.output.string).to eq(expected_output)
    end

    it "cycles around when configured to do so" do
      prompt = TTY::TestPrompt.new
      choices = %w(A B C)
      prompt.on(:keypress) { |e| prompt.trigger(:keydown) if e.value == "j" }
      prompt.input << "j" << "j" << "j" << "\r"
      prompt.input.rewind

      answer = prompt.select("What letter?", choices, cycle: true)

      expect(answer).to eq("A")
      expected_output = [
        output_helper("What letter?", choices, "A", init: true,
          hint: "Use #{up_down} arrow keys, press Enter to select"),
        output_helper("What letter?", choices, "B"),
        output_helper("What letter?", choices, "C"),
        output_helper("What letter?", choices, "A"),
        "What letter? \e[32mA\e[0m\n\e[?25h"
      ].join
      expect(prompt.output.string).to eq(expected_output)
    end

    it "cycles around disabled items" do
      prompt = TTY::TestPrompt.new
      choices = [
        {name: 'A', disabled: '(out)'},
        {name: 'B'},
        {name: 'C', disabled: '(out)'},
        {name: 'D'},
        {name: 'E', disabled: '(out)'},
      ]
      prompt.on(:keypress) { |e| prompt.trigger(:keydown) if e.value == "j" }
      prompt.input << "j" << "j" << "j" << "\r"
      prompt.input.rewind
      value = prompt.select("What letter?", choices, cycle: true, default: 2)
      expect(value).to eq("D")

      expected_output =
        output_helper("What letter?", choices, "B", init: true,
                       hint: "Use #{up_down} arrow keys, press Enter to select") +
        output_helper("What letter?", choices, "D") +
        output_helper("What letter?", choices, "B") +
        output_helper("What letter?", choices, "D") +
        "What letter? \e[32mD\e[0m\n\e[?25h"

      expect(prompt.output.string).to eq(expected_output)
    end

    it "cycles choices using left/right arrows" do
      prompt = TTY::TestPrompt.new
      choices = ('1'..'10').to_a
      prompt.on(:keypress) { |e|
        prompt.trigger(:keyright) if e.value == "l"
        prompt.trigger(:keyleft) if e.value == "h"
      }
      prompt.input << "l" << "l" << "l" << "h" << "\r"
      prompt.input.rewind

      answer = prompt.select("What number?", choices, default: 2, per_page: 4, cycle: true)

      expect(answer).to eq('10')

      expected_output = [
        output_helper('What number?', choices[0..3], "2", init: true,
          hint: "Use #{up_down} and #{left_right} arrow keys, press Enter to select"),
        output_helper('What number?', choices[4..7], "6"),
        output_helper('What number?', choices[8..9], "10"),
        output_helper('What number?', choices[0..3], "2"),
        output_helper('What number?', choices[8..9], "10"),
        "What number? \e[32m10\e[0m\n\e[?25h",
      ].join

      expect(prompt.output.string).to eq(expected_output)
    end

    it "cycles pages left/right with disabled items" do
      prompt = TTY::TestPrompt.new
      prompt.on(:keypress) { |e|
        prompt.trigger(:keyright) if e.value == "l"
        prompt.trigger(:keyleft)  if e.value == "h"
      }
      choices = [
        {name: '1', disabled: 'out'},
        '2',
        {name: '3', disabled: 'out'},
        '4',
        '5',
        {name: '6', disabled: 'out'},
        '7',
        '8',
        '9',
        {name: '10', disabled: 'out'}
      ]

      prompt.input << "l" << "l" << "l" << "h" << "h" << "h" << "\r"
      prompt.input.rewind

      answer = prompt.select("What number?", choices, per_page: 4, cycle: true)

      expect(answer).to eq('2')

      expected_output = [
        output_helper('What number?', choices[0..3], "2", init: true,
          hint: "Use #{up_down} and #{left_right} arrow keys, press Enter to select"),
        output_helper('What number?', choices[4..7], "7"),
        output_helper('What number?', choices[8..9], "9"),
        output_helper('What number?', choices[0..3], "2"),
        output_helper('What number?', choices[8..9], "9"),
        output_helper('What number?', choices[4..7], "5"),
        output_helper('What number?', choices[0..3], "2"),
        "What number? \e[32m2\e[0m\n\e[?25h"
      ].join('')

      expect(prompt.output.string).to eq(expected_output)
    end
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

  it "doesn't paginate short selections" do
    prompt = TTY::TestPrompt.new
    choices = %w(A B C D)
    prompt.input << "\r"
    prompt.input.rewind
    value = prompt.select("What letter?", choices, per_page: 4, default: 1)
    expect(value).to eq('A')

    expect(prompt.output.string).to eq([
      "\e[?25lWhat letter? \e[90m(Use #{up_down} arrow keys, press Enter to select)\e[0m\n",
      "\e[32m#{symbols[:marker]} A\e[0m\n",
      "  B\n",
      "  C\n",
      "  D",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G",
      "What letter? \e[32mA\e[0m\n\e[?25h",
    ].join)
  end

  it "verifies default index range" do
    prompt = TTY::TestPrompt.new
    choices = %w(Large Medium Small)
    prompt.input << "\r"
    prompt.input.rewind

    expect {
      prompt.select("What size?", choices, default: 10)
    }.to raise_error(TTY::Prompt::ConfigurationError, /`10` out of range \(1 - 3\)/)
  end

  context "with filter" do
    it "doesn't allow mixing enumeration and filter" do
      prompt = TTY::TestPrompt.new

      expect {
        prompt.select("What size?", [], enum: '.', filter: true)
      }.to raise_error(TTY::Prompt::ConfigurationError, "Enumeration can't be used with filter")
    end

    it "filters and chooses a uniquely matching entry, ignoring case" do
      prompt = TTY::TestPrompt.new
      prompt.input << "U" << "g" << "\r"
      prompt.input.rewind

      answer = prompt.select("What size?", %w(Small Medium Large Huge), filter: true)
      expect(answer).to eql("Huge")

      actual_prompt_output = prompt.output.string

      expected_prompt_output =
        output_helper("What size?", %w(Small Medium Large Huge), "Small", init: true,
          hint: "Use #{up_down} arrow keys, press Enter to select, and letter keys to filter") +
        output_helper("What size?", %w(Medium Huge), "Medium", hint: 'Filter: "U"') +
        output_helper("What size?", %w(Huge), "Huge", hint: 'Filter: "Ug"') +
        exit_message("What size?", "Huge")

      expect(actual_prompt_output).to eql(expected_prompt_output)
    end

    it "filters and chooses the first of multiple matching entries" do
      prompt = TTY::TestPrompt.new
      prompt.input << "g" << "\r"
      prompt.input.rewind

      answer = prompt.select("What size?", %w(Small Medium Large Huge), filter: true)
      expect(answer).to eql("Large")

      actual_prompt_output = prompt.output.string
      expected_prompt_output =
        output_helper("What size?", %w(Small Medium Large Huge), "Small", init: true,
          hint: "Use #{up_down} arrow keys, press Enter to select, and letter keys to filter") +
        output_helper("What size?", %w(Large Huge), "Large", hint: 'Filter: "g"') +
        exit_message("What size?", "Large")

      expect(actual_prompt_output).to eql(expected_prompt_output)
    end

    it "filters based on alphanumeric and punctuation characters" do
      prompt = TTY::TestPrompt.new
      prompt.input << "p" << "*" << "2" << "\r"
      prompt.input.rewind

      answer = prompt.select("What email?", %w(p*1@mail.com p*2@mail.com p*3@mail.com), filter: true)
      expect(answer).to eql("p*2@mail.com")

      actual_prompt_output = prompt.output.string
      expected_prompt_output =
        output_helper("What email?", %w(p*1@mail.com p*2@mail.com p*3@mail.com), "p*1@mail.com", init: true,
          hint: "Use #{up_down} arrow keys, press Enter to select, and letter keys to filter") +
        output_helper("What email?", %w(p*1@mail.com p*2@mail.com p*3@mail.com), "p*1@mail.com", hint: 'Filter: "p"') +
        output_helper("What email?", %w(p*1@mail.com p*2@mail.com p*3@mail.com), "p*1@mail.com", hint: 'Filter: "p*"') +
        output_helper("What email?", %w(p*2@mail.com), "p*2@mail.com", hint: 'Filter: "p*2"') +
        exit_message("What email?", "p*2@mail.com")

      expect(actual_prompt_output).to eql(expected_prompt_output)
    end

    # This test can't be done in an exact way, at least, with the current framework
    it "doesn't exit when there are no matching entries" do
      prompt = TTY::TestPrompt.new
      prompt.on(:keypress) { |e| prompt.trigger(:keybackspace) if e.value == "a" }
      prompt.input << "z" << "\r"    # shows no entry, blocking exit
      prompt.input << "a" << "\r"    # triggers Backspace before `a` (see above)
      prompt.input.rewind

      answer = prompt.select("What size?", %w(Tiny Medium Large Huge), filter: true)
      expect(answer).to eql("Large")

      actual_prompt_output = prompt.output.string
      expected_prompt_output =
        output_helper("What size?", %w(Tiny Medium Large Huge), "Tiny", init: true,
          hint: "Use #{up_down} arrow keys, press Enter to select, and letter keys to filter") +
        output_helper("What size?", %w(), "", hint: 'Filter: "z"') +
        output_helper("What size?", %w(), "", hint: 'Filter: "z"') +
        output_helper("What size?", %w(Large), "Large", hint: 'Filter: "a"') +
        exit_message("What size?", "Large")

      expect(actual_prompt_output).to eql(expected_prompt_output)
    end

    it "cancels a selection" do
      prompt = TTY::TestPrompt.new
      prompt.on(:keypress) { |e| prompt.trigger(:keydelete) if e.value == "S" }
      prompt.input << "Hu"
      prompt.input << "S"   # triggers Canc before `S` (see above)
      prompt.input << "\r"
      prompt.input.rewind

      answer = prompt.select("What size?", %w(Small Medium Large Huge), filter: true)
      expect(answer).to eql("Small")

      expected_prompt_output =
        output_helper("What size?", %w(Small Medium Large Huge), "Small", init: true,
          hint: "Use #{up_down} arrow keys, press Enter to select, and letter keys to filter") +
        output_helper("What size?", %w(Huge), "Huge", hint: 'Filter: "H"') +
        output_helper("What size?", %w(Huge), "Huge", hint: 'Filter: "Hu"') +
        output_helper("What size?", %w(Small), "Small", hint: 'Filter: "S"') +
        exit_message("What size?", "Small")

      expect(prompt.output.string).to eql(expected_prompt_output)
    end
  end

  context 'with :disabled choice' do
    it "omits disabled choice when navigating menu" do
      choices = [ 'Small', 'Medium', {name: 'Large', disabled: '(out of stock)'}, 'Huge' ]
      prompt = TTY::TestPrompt.new
      prompt.input << "j" << "j" << "\r"
      prompt.input.rewind
      prompt.on(:keypress) { |e| prompt.trigger(:keydown) if e.value == "j" }

      answer = prompt.select("What size?", choices)
      expect(answer).to eq('Huge')

      expected_output =
        output_helper("What size?", choices, "Small", init: true,
          hint: "Use #{up_down} arrow keys, press Enter to select") +
        output_helper("What size?", choices, "Medium") +
        output_helper("What size?", choices, "Huge") +
        "What size? \e[32mHuge\e[0m\n\e[?25h"

      expect(prompt.output.string).to eq(expected_output)
    end

    it "doesn't show disabled choice when filtering choices" do
      choices = [ 'A', 'B', {name: 'C', disabled: '(unavailable)'}, 'D' ]
      prompt = TTY::TestPrompt.new
      prompt.on(:keypress) { |e| prompt.trigger(:keybackspace) if e.value == "a" }
      prompt.input << "c" << "\r" # nothing matches
      prompt.input << "a" << "\r" # backtracks & chooses default option
      prompt.input.rewind

      answer = prompt.select("What letter?", choices, filter: true)
      expect(answer).to eq('A')

      expected_output =
        output_helper("What letter?", choices, "A", init: true,
          hint: "Use #{up_down} arrow keys, press Enter to select, and letter keys to filter") +
        output_helper("What letter?", [], "", hint: 'Filter: "c"') +
        output_helper("What letter?", [], "", hint: 'Filter: "c"') +
        output_helper("What letter?", ['A'], "A", hint: 'Filter: "a"') +
        exit_message("What letter?", "A")

      expect(prompt.output.string).to eq(expected_output)
    end

    it "omits disabled choice when number key is pressed" do
      choices = [ 'Small', {name: 'Medium', disabled: '(out of stock)'}, 'Large' ]
      prompt = TTY::TestPrompt.new
      prompt.input << "2" << "\r" << "\r"
      prompt.input.rewind
      answer = prompt.select('What size?') do |menu|
                 menu.enum ')'

                 menu.choice 'Small', 1
                 menu.choice 'Medium', 2, disabled: '(out of stock)'
                 menu.choice 'Large', 3
               end
      expect(answer).to eq(1)

      expected_output =
        output_helper("What size?", choices, "Small", init: true, enum: ') ',
          hint: "Use #{up_down} arrow or number (1-3) keys, press Enter to select") +
        output_helper("What size?", choices, "Small", enum: ') ') +
        "What size? \e[32mSmall\e[0m\n\e[?25h"

      expect(prompt.output.string).to eq(expected_output)
    end

    it "sets active to be first non-disabled choice" do
      choices = [
        {name: 'Small', disabled: '(out of stock)'}, 'Medium', 'Large', 'Huge'
      ]
      prompt = TTY::TestPrompt.new
      prompt.input << "\r"
      prompt.input.rewind

      answer = prompt.select("What size?", choices)
      expect(answer).to eq('Medium')
    end

    it "prevents setting default to disabled choice" do
      choices = [
        {name: 'Small', disabled: '(out of stock)'}, 'Medium', 'Large', 'Huge'
      ]
      prompt = TTY::TestPrompt.new
      prompt.input << "\r"
      prompt.input.rewind

      expect {
        prompt.select("What size?", choices, default: 1)
      }.to raise_error(TTY::Prompt::ConfigurationError, /default index `1` matches disabled choice item/)
    end
  end
end
