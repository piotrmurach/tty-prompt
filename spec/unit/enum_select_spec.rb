# frozen_string_literal: true

RSpec.describe TTY::Prompt do
  let(:symbols) { TTY::Prompt::Symbols.symbols }

  def output_helper(prompt, choices, active, options = {})
    enum    = options.fetch(:enum, ')')
    input   = options[:input]
    error   = options[:error]
    default = options.fetch(:default, 1)

    out  = []
    out << prompt << " \n"
    out << choices.map.with_index do |c, i|
      name = c.is_a?(Hash) ? c[:name] : c
      disabled = c.is_a?(Hash) ? c[:disabled] : false
      num = (i + 1).to_s + enum
      if disabled
        "\e[31m#{symbols[:cross]}\e[0m #{num} #{name} #{disabled}"
      elsif name == active
        "  \e[32m#{num} #{name}\e[0m"
      else
        "  #{num} #{name}"
      end
    end.join("\n")
    out << "\n"
    choice =  "  Choose 1-#{choices.count} [#{default}]: "
    choice = choice + input.to_s if input
    out << choice
    if error
      out << "\n"
      out << "\e[31m>>\e[0m #{error}"
      out << "\e[A\e[1G\e[#{choice.size}C"
    end
    out << "\e[2K\e[1G\e[1A" * (choices.count + 1)
    out << "\e[2K\e[1G\e[J"
    out.join
  end

  def exit_message(prompt, choice)
    "#{prompt} \e[32m#{choice}\e[0m\n"
  end

  it "raises configuration error when wrong default" do
    prompt = TTY::TestPrompt.new
    choices = %w(/bin/nano /usr/bin/vim.basic /usr/bin/vim.tiny)

    expect {
      prompt.enum_select("Select an editor?", choices, default: 100)
    }.to raise_error(TTY::Prompt::ConfigurationError,
                     /default index 100 out of range \(1 - 3\)/)
  end

  it "selects default option when return pressed immediately" do
    choices = %w(/bin/nano /usr/bin/vim.basic /usr/bin/vim.tiny)
    prompt = TTY::TestPrompt.new
    prompt.input << "\n"
    prompt.input.rewind

    answer = prompt.enum_select("Select an editor?", choices)
    expect(answer).to eq('/bin/nano')

    expected_output = [
      output_helper("Select an editor?", choices, "/bin/nano"),
      exit_message("Select an editor?", "/bin/nano")
    ].join

    expect(prompt.output.string).to eq(expected_output)
  end

  it "selects option by index from the list" do
    choices = %w(/bin/nano /usr/bin/vim.basic /usr/bin/vim.tiny)
    prompt = TTY::TestPrompt.new
    prompt.input << "3\n"
    prompt.input.rewind

    answer = prompt.enum_select("Select an editor?", choices, default: 2)
    expect(answer).to eq('/usr/bin/vim.tiny')

    expected_output = [
      output_helper("Select an editor?", choices, "/usr/bin/vim.basic", default: 2),
      output_helper("Select an editor?", choices, "/usr/bin/vim.tiny", default: 2, input: '3'),
      exit_message("Select an editor?", "/usr/bin/vim.tiny")
    ].join

    expect(prompt.output.string).to eq(expected_output)
  end

  it "selects option through DSL" do
    choices = %w(/bin/nano /usr/bin/vim.basic /usr/bin/vim.tiny)
    prompt = TTY::TestPrompt.new
    prompt.input << "1\n"
    prompt.input.rewind
    answer = prompt.enum_select("Select an editor?") do |menu|
      menu.default 2
      menu.enum '.'

      menu.choice "/bin/nano"
      menu.choice "/usr/bin/vim.basic"
      menu.choice "/usr/bin/vim.tiny"
    end
    expect(answer).to eq('/bin/nano')

    expected_output = [
      output_helper("Select an editor?", choices, "/usr/bin/vim.basic", default: 2, enum: '.'),
      output_helper("Select an editor?", choices, "/bin/nano", default: 2, enum: '.', input: 1),
      exit_message("Select an editor?", "/bin/nano")
    ].join

    expect(prompt.output.string).to eq(expected_output)
  end

  it "selects option through DSL with key and value" do
    choices = %w(nano vim emacs)
    prompt = TTY::TestPrompt.new
    prompt.input << "\n"
    prompt.input.rewind

    answer = prompt.enum_select("Select an editor?") do |menu|
      menu.default 2

      menu.choice :nano,  '/bin/nano'
      menu.choice :vim,   '/usr/bin/vim'
      menu.choice :emacs, '/usr/bin/emacs'
    end

    expect(answer).to eq('/usr/bin/vim')

    expected_output = [
      output_helper("Select an editor?", choices, "vim", default: 2),
      exit_message("Select an editor?", "vim")
    ].join

    expect(prompt.output.string).to eq(expected_output)
  end

  it "changes colors for selection, hint and error" do
    prompt = TTY::TestPrompt.new
    choices = %w(/bin/nano /usr/bin/vim.basic /usr/bin/vim.tiny)
    prompt.input << "\n"
    prompt.input.rewind
    options = {active_color: :red, help_color: :blue, error_color: :green}

    answer = prompt.enum_select("Select an editor?", choices, options)

    expect(answer).to eq('/bin/nano')

    expected_output = [
      "Select an editor? \n",
      "  \e[31m1) /bin/nano\e[0m\n",
      "  2) /usr/bin/vim.basic\n",
      "  3) /usr/bin/vim.tiny\n",
      "  Choose 1-3 [1]: ",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "Select an editor? \e[31m/bin/nano\e[0m\n"
    ].join

    expect(prompt.output.string).to eq(expected_output)
  end

  it "changes global symbols" do
    prompt = TTY::TestPrompt.new(symbols: {cross: 'x'})
    choices = ['A', {name: 'B', disabled: '(out)'}, 'C']
    prompt.input << "\n"
    prompt.input.rewind
    answer = prompt.enum_select("What letter?", choices)
    expect(answer).to eq("A")

    expected_output = [
      "What letter? \n",
      "  \e[32m1) A\e[0m\n",
      "\e[31mx\e[0m 2) B (out)\n",
      "  3) C\n",
      "  Choose 1-3 [1]: ",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "What letter? \e[32mA\e[0m\n",
    ].join

    expect(prompt.output.string).to eq(expected_output)
  end

  it "changes global symbols through DSL" do
    prompt = TTY::TestPrompt.new
    choices = ['A', {name: 'B', disabled: '(out)'}, 'C']
    prompt.input << "\n"
    prompt.input.rewind
    answer = prompt.enum_select("What letter?", choices) do |menu|
               menu.symbols cross: 'x'
               menu.choices choices
             end
    expect(answer).to eq("A")

    expected_output = [
      "What letter? \n",
      "  \e[32m1) A\e[0m\n",
      "\e[31mx\e[0m 2) B (out)\n",
      "  3) C\n",
      "  Choose 1-3 [1]: ",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "What letter? \e[32mA\e[0m\n",
    ].join

    expect(prompt.output.string).to eq(expected_output)
  end

  it "displays error with unrecognized input" do
    choices = %w(/bin/nano /usr/bin/vim.basic /usr/bin/vim.tiny)
    prompt = TTY::TestPrompt.new
    prompt.input << "11\n2\n"
    prompt.input.rewind

    answer = prompt.enum_select("Select an editor?", choices)
    expect(answer).to eq('/usr/bin/vim.basic')

    expected_output = [
      output_helper("Select an editor?", choices, "/bin/nano"),
      output_helper("Select an editor?", choices, "/bin/nano", input: '1'),
      output_helper("Select an editor?", choices, "/bin/nano", input: '11'),
      output_helper("Select an editor?", choices, "/bin/nano", error: 'Please enter a valid number', input: ''),
      output_helper("Select an editor?", choices, "/usr/bin/vim.basic", error: 'Please enter a valid number', input: '2'),
      exit_message("Select an editor?", "/usr/bin/vim.basic")
    ].join

    expect(prompt.output.string).to eq(expected_output)
  end

  it "paginates long selections" do
    choices = %w(A B C D E F G H)
    prompt = TTY::TestPrompt.new
    prompt.input << "\n"
    prompt.input.rewind

    answer = prompt.enum_select("What letter?", choices, per_page: 3, default: 4)
    expect(answer).to eq('D')

    expect(prompt.output.string).to eq([
      "What letter? \n",
      "  \e[32m4) D\e[0m\n",
      "  5) E\n",
      "  6) F\n",
      "  Choose 1-8 [4]: ",
      "\n\e[90m(Press tab/right or left to reveal more choices)\e[0m",
      "\e[A\e[1G\e[18C",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "What letter? \e[32mD\e[0m\n"
    ].join)
  end

  it "doesn't paginate short selections" do
    choices = %i(A B C D)
    prompt = TTY::TestPrompt.new
    prompt.input << "\r"
    prompt.input.rewind

    answer = prompt.enum_select("What letter?", choices, per_page: 4, default: 1)
    expect(answer).to eq(:A)

    expected_output =
      output_helper("What letter?", choices, :A) +
      exit_message("What letter?", :A)

    expect(prompt.output.string).to eq(expected_output)
  end

  it "shows pages matching input" do
    prompt = TTY::TestPrompt.new
    choices = %w(A B C D E F G H)
    prompt.input << "11\n\b\n"
    prompt.input.rewind
    value = prompt.enum_select("What letter?", choices, per_page: 3)
    expect(value).to eq('A')
    expect(prompt.output.string).to eq([
      "What letter? \n",
      "  \e[32m1) A\e[0m\n",
      "  2) B\n",
      "  3) C\n",
      "  Choose 1-8 [1]: ",
      "\n\e[90m(Press tab/right or left to reveal more choices)\e[0m",
      "\e[A\e[1G\e[18C",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "What letter? \n",
      "  \e[32m1) A\e[0m\n",
      "  2) B\n",
      "  3) C\n",
      "  Choose 1-8 [1]: 1",
      "\n\e[90m(Press tab/right or left to reveal more choices)\e[0m",
      "\e[A\e[1G\e[19C",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "What letter? \n",
      "  \e[32m1) A\e[0m\n",
      "  2) B\n",
      "  3) C\n",
      "  Choose 1-8 [1]: 11",
      "\n\e[90m(Press tab/right or left to reveal more choices)\e[0m",
      "\e[A\e[1G\e[20C",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "What letter? \n",
      "  \e[32m1) A\e[0m\n",
      "  2) B\n",
      "  3) C\n",
      "  Choose 1-8 [1]: \n",
      "\e[31m>>\e[0m Please enter a valid number",
      "\n\e[90m(Press tab/right or left to reveal more choices)\e[0m",
      "\e[A\e[1G\e[A\e[1G\e[18C",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "What letter? \n",
      "  \e[32m1) A\e[0m\n",
      "  2) B\n",
      "  3) C\n",
      "  Choose 1-8 [1]: \n",
      "\e[31m>>\e[0m Please enter a valid number",
      "\n\e[90m(Press tab/right or left to reveal more choices)\e[0m",
      "\e[A\e[1G\e[A\e[1G\e[18C",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "What letter? \e[32mA\e[0m\n"
    ].join)
  end

  it "switches through pages with tab key" do
    prompt = TTY::TestPrompt.new
    choices = %w(A B C D E F G H)
    prompt.input << "\t\n"
    prompt.input.rewind
    value = prompt.enum_select("What letter?") do |menu|
              menu.default 4
              menu.per_page 3
              menu.choices choices
            end
    expect(value).to eq('D')
    expect(prompt.output.string).to eq([
      "What letter? \n",
      "  \e[32m4) D\e[0m\n",
      "  5) E\n",
      "  6) F\n",
      "  Choose 1-8 [4]: ",
      "\n\e[90m(Press tab/right or left to reveal more choices)\e[0m",
      "\e[A\e[1G\e[18C",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "What letter? \n",
      "  7) G\n",
      "  8) H\n",
      "  Choose 1-8 [4]: ",
      "\n\e[90m(Press tab/right or left to reveal more choices)\e[0m",
      "\e[A\e[1G\e[18C",
      "\e[2K\e[1G\e[1A" * 3,
      "\e[2K\e[1G\e[J",
      "What letter? \e[32mD\e[0m\n"
    ].join)
  end

  it "doesn't cycle around by default" do
    prompt = TTY::TestPrompt.new
    choices = %w(A B C D E F)
    prompt.input << "\t" << "\t" << "\n"
    prompt.input.rewind
    value = prompt.enum_select("What letter?") do |menu|
              menu.default 1
              menu.per_page 3
              menu.choices choices
            end
    expect(value).to eq("A")
    expect(prompt.output.string).to eq([
      "What letter? \n",
      "  \e[32m1) A\e[0m\n",
      "  2) B\n",
      "  3) C\n",
      "  Choose 1-6 [1]: ",
      "\n\e[90m(Press tab/right or left to reveal more choices)\e[0m",
      "\e[A\e[1G\e[18C",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "What letter? \n",
      "  4) D\n",
      "  5) E\n",
      "  6) F\n",
      "  Choose 1-6 [1]: ",
      "\n\e[90m(Press tab/right or left to reveal more choices)\e[0m",
      "\e[A\e[1G\e[18C",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "What letter? \n",
      "  4) D\n",
      "  5) E\n",
      "  6) F\n",
      "  Choose 1-6 [1]: ",
      "\n\e[90m(Press tab/right or left to reveal more choices)\e[0m",
      "\e[A\e[1G\e[18C",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "What letter? \e[32mA\e[0m\n"
    ].join)
  end

  it "cycles around when configured to do so" do
    prompt = TTY::TestPrompt.new
    choices = %w(A B C D E F)
    prompt.input << "\t" << "\t" << "\n"
    prompt.input.rewind
    value = prompt.enum_select("What letter?", cycle: true) do |menu|
              menu.default 1
              menu.per_page 3
              menu.choices choices
            end
    expect(value).to eq("A")

    expect(prompt.output.string).to eq([
      "What letter? \n",
      "  \e[32m1) A\e[0m\n",
      "  2) B\n",
      "  3) C\n",
      "  Choose 1-6 [1]: ",
      "\n\e[90m(Press tab/right or left to reveal more choices)\e[0m",
      "\e[A\e[1G\e[18C",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "What letter? \n",
      "  4) D\n",
      "  5) E\n",
      "  6) F\n",
      "  Choose 1-6 [1]: ",
      "\n\e[90m(Press tab/right or left to reveal more choices)\e[0m",
      "\e[A\e[1G\e[18C",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "What letter? \n",
      "  \e[32m1) A\e[0m\n",
      "  2) B\n",
      "  3) C\n",
      "  Choose 1-6 [1]: ",
      "\n\e[90m(Press tab/right or left to reveal more choices)\e[0m",
      "\e[A\e[1G\e[18C",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "What letter? \e[32mA\e[0m\n"
    ].join)
  end

  context "with :disabled choice" do
    it "fails when active item is also disabled" do
      prompt = TTY::TestPrompt.new
      choices = [{name: 'A', disabled: true}, 'B', 'C', 'D', 'E']
      expect {
        prompt.enum_select("What letter?", choices, default: 1)
      }.to raise_error(TTY::Prompt::ConfigurationError,
        /default index 1 matches disabled choice item/)
    end

    it "finds first non-disabled index" do
      prompt = TTY::TestPrompt.new
      choices = [{name: 'A', disabled: true}, {name:'B', disabled: true}, 'C', 'D']
      prompt = TTY::TestPrompt.new
      prompt.input << "\n"
      prompt.input.rewind

      answer = prompt.enum_select("What letter?", choices)
      expect(answer).to eq('C')
    end

    it "doesn't allow to choose disabled choice and defaults" do
      choices = ['A', {name: 'B', disabled: '(out)'}, 'C', 'D', 'E', 'F']
      prompt = TTY::TestPrompt.new
      prompt.input << "2" << "\n" << "3" << "\n"
      prompt.input.rewind

      answer = prompt.enum_select("What letter?", choices)
      expect(answer).to eq("C")

      expected_output = [
        output_helper("What letter?", choices, 'A'),
        output_helper("What letter?", choices, 'A', input: '2'),
        output_helper("What letter?", choices, 'A', input: '', error: 'Please enter a valid number'),
        output_helper("What letter?", choices, 'C', input: '3', error: 'Please enter a valid number'),
        exit_message("What letter?", "C")
      ].join

      expect(prompt.output.string).to eq(expected_output)
    end

    it "omits disabled choice when navigating with numbers" do
      choices = [
        {name: 'A'},
        {name: 'B', disabled: '(out)'},
        {name: 'C', disabled: '(out)'},
        {name: 'D'},
        {name: 'E'}
      ]
      prompt = TTY::TestPrompt.new
      prompt.on(:keypress) { |e| prompt.trigger(:keydelete) if e.value == "B"}
      prompt.input << "2" << "\u007F" << "3" << "\u007F" << '4' << "\n"
      prompt.input.rewind

      answer = prompt.enum_select("What letter?", choices)
      expect(answer).to eq("D")

      expected_output = [
        output_helper("What letter?", choices, 'A'),
        output_helper("What letter?", choices, 'A', input: '2'),
        output_helper("What letter?", choices, 'A', input: ''),
        output_helper("What letter?", choices, 'A', input: '3'),
        output_helper("What letter?", choices, 'A', input: ''),
        output_helper("What letter?", choices, 'D', input: '4'),
        exit_message("What letter?", "D")
      ].join

      expect(prompt.output.string).to eq(expected_output)
    end
  end
end
