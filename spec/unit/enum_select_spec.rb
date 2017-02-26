# encoding: utf-8

RSpec.describe TTY::Prompt do
  it "selects default option when return pressed immediately" do
    prompt = TTY::TestPrompt.new
    choices = %w(/bin/nano /usr/bin/vim.basic /usr/bin/vim.tiny)
    prompt.input << "\n"
    prompt.input.rewind

    expect(prompt.enum_select("Select an editor?", choices)).to eq('/bin/nano')
    expect(prompt.output.string).to eq([
      "Select an editor? \n",
      "\e[32m  1) /bin/nano\e[0m\n",
      "  2) /usr/bin/vim.basic\n",
      "  3) /usr/bin/vim.tiny\n",
      "  Choose 1-3 [1]: ",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "Select an editor? \e[32m/bin/nano\e[0m\n"
    ].join)
  end

  it "selects option by index from the list" do
    prompt = TTY::TestPrompt.new
    choices = %w(/bin/nano /usr/bin/vim.basic /usr/bin/vim.tiny)
    prompt.input << "3\n"
    prompt.input.rewind

    expect(prompt.enum_select("Select an editor?", choices, default: 2)).to eq('/usr/bin/vim.tiny')
    expect(prompt.output.string).to eq([
      "Select an editor? \n",
      "  1) /bin/nano\n",
      "\e[32m  2) /usr/bin/vim.basic\e[0m\n",
      "  3) /usr/bin/vim.tiny\n",
      "  Choose 1-3 [2]: ",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "Select an editor? \n",
      "  1) /bin/nano\n",
      "  2) /usr/bin/vim.basic\n",
      "\e[32m  3) /usr/bin/vim.tiny\e[0m\n",
      "  Choose 1-3 [2]: 3",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "Select an editor? \e[32m/usr/bin/vim.tiny\e[0m\n"
    ].join)
  end

  it "selects option through DSL" do
    prompt = TTY::TestPrompt.new
    prompt.input << "1\n"
    prompt.input.rewind
    value = prompt.enum_select("Select an editor?") do |menu|
      menu.default 2
      menu.enum '.'

      menu.choice "/bin/nano"
      menu.choice "/usr/bin/vim.basic"
      menu.choice "/usr/bin/vim.tiny"
    end

    expect(value).to eq('/bin/nano')
    expect(prompt.output.string).to eq([
      "Select an editor? \n",
      "  1. /bin/nano\n",
      "\e[32m  2. /usr/bin/vim.basic\e[0m\n",
      "  3. /usr/bin/vim.tiny\n",
      "  Choose 1-3 [2]: ",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "Select an editor? \n",
      "\e[32m  1. /bin/nano\e[0m\n",
      "  2. /usr/bin/vim.basic\n",
      "  3. /usr/bin/vim.tiny\n",
      "  Choose 1-3 [2]: 1",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "Select an editor? \e[32m/bin/nano\e[0m\n"
    ].join)
  end

  it "selects option through DSL with key and value" do
    prompt = TTY::TestPrompt.new
    prompt.input << "\n"
    prompt.input.rewind
    value = prompt.enum_select("Select an editor?") do |menu|
      menu.default 2

      menu.choice :nano,  '/bin/nano'
      menu.choice :vim,   '/usr/bin/vim'
      menu.choice :emacs, '/usr/bin/emacs'
    end

    expect(value).to eq('/usr/bin/vim')
    expect(prompt.output.string).to eq([
      "Select an editor? \n",
      "  1) nano\n",
      "\e[32m  2) vim\e[0m\n",
      "  3) emacs\n",
      "  Choose 1-3 [2]: ",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "Select an editor? \e[32mvim\e[0m\n"
    ].join)
  end

  it "changes colors for selection, hint and error" do
    prompt = TTY::TestPrompt.new
    choices = %w(/bin/nano /usr/bin/vim.basic /usr/bin/vim.tiny)
    prompt.input << "\n"
    prompt.input.rewind
    options = {active_color: :red, help_color: :blue, error_color: :green}
    expect(prompt.enum_select("Select an editor?", choices, options)).to eq('/bin/nano')
    expect(prompt.output.string).to eq([
      "Select an editor? \n",
      "\e[31m  1) /bin/nano\e[0m\n",
      "  2) /usr/bin/vim.basic\n",
      "  3) /usr/bin/vim.tiny\n",
      "  Choose 1-3 [1]: ",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "Select an editor? \e[31m/bin/nano\e[0m\n"
    ].join)
  end

  it "displays error with unrecognized input" do
    prompt = TTY::TestPrompt.new
    choices = %w(/bin/nano /usr/bin/vim.basic /usr/bin/vim.tiny)
    prompt.input << "11\n2\n"
    prompt.input.rewind
    value = prompt.enum_select("Select an editor?", choices)
    expect(value).to eq('/usr/bin/vim.basic')
    expect(prompt.output.string).to eq([
      "Select an editor? \n",
      "\e[32m  1) /bin/nano\e[0m\n",
      "  2) /usr/bin/vim.basic\n",
      "  3) /usr/bin/vim.tiny\n",
      "  Choose 1-3 [1]: ",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "Select an editor? \n",
      "\e[32m  1) /bin/nano\e[0m\n",
      "  2) /usr/bin/vim.basic\n",
      "  3) /usr/bin/vim.tiny\n",
      "  Choose 1-3 [1]: 1",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "Select an editor? \n",
      "\e[32m  1) /bin/nano\e[0m\n",
      "  2) /usr/bin/vim.basic\n",
      "  3) /usr/bin/vim.tiny\n",
      "  Choose 1-3 [1]: 11",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "Select an editor? \n",
      "\e[32m  1) /bin/nano\e[0m\n",
      "  2) /usr/bin/vim.basic\n",
      "  3) /usr/bin/vim.tiny\n",
      "  Choose 1-3 [1]: \n",
      "\e[31m>>\e[0m Please enter a valid number",
      "\e[A\e[1G\e[18C",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "Select an editor? \n",
      "  1) /bin/nano\n",
      "\e[32m  2) /usr/bin/vim.basic\e[0m\n",
      "  3) /usr/bin/vim.tiny\n",
      "  Choose 1-3 [1]: 2\n",
      "\e[31m>>\e[0m Please enter a valid number",
      "\e[A\e[1G\e[19C",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "Select an editor? \e[32m/usr/bin/vim.basic\e[0m\n"
    ].join)
  end

  it "paginates long selections" do
    prompt = TTY::TestPrompt.new
    choices = %w(A B C D E F G H)
    prompt.input << "\n"
    prompt.input.rewind
    value = prompt.enum_select("What letter?", choices, per_page: 3, default: 4)
    expect(value).to eq('D')
    expect(prompt.output.string).to eq([
      "What letter? \n",
      "\e[32m  4) D\e[0m\n",
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
    prompt = TTY::TestPrompt.new
    choices = %w(A B C D)
    prompt.input << "\r"
    prompt.input.rewind
    value = prompt.enum_select("What letter?", choices, per_page: 4, default: 1)
    expect(value).to eq('A')

    expect(prompt.output.string).to eq([
      "What letter? \n",
      "\e[32m  1) A\e[0m\n",
      "  2) B\n",
      "  3) C\n",
      "  4) D\n",
      "  Choose 1-4 [1]: ",
      "\e[2K\e[1G\e[1A" * 5,
      "\e[2K\e[1G\e[J",
      "What letter? \e[32mA\e[0m\n"
    ].join)
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
      "\e[32m  1) A\e[0m\n",
      "  2) B\n",
      "  3) C\n",
      "  Choose 1-8 [1]: ",
      "\n\e[90m(Press tab/right or left to reveal more choices)\e[0m",
      "\e[A\e[1G\e[18C",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "What letter? \n",
      "\e[32m  1) A\e[0m\n",
      "  2) B\n",
      "  3) C\n",
      "  Choose 1-8 [1]: 1",
      "\n\e[90m(Press tab/right or left to reveal more choices)\e[0m",
      "\e[A\e[1G\e[19C",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "What letter? \n",
      "\e[32m  1) A\e[0m\n",
      "  2) B\n",
      "  3) C\n",
      "  Choose 1-8 [1]: 11",
      "\n\e[90m(Press tab/right or left to reveal more choices)\e[0m",
      "\e[A\e[1G\e[20C",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "What letter? \n",
      "\e[32m  1) A\e[0m\n",
      "  2) B\n",
      "  3) C\n",
      "  Choose 1-8 [1]: \n",
      "\e[31m>>\e[0m Please enter a valid number",
      "\n\e[90m(Press tab/right or left to reveal more choices)\e[0m",
      "\e[A\e[1G\e[A\e[1G\e[18C",
      "\e[2K\e[1G\e[1A" * 4,
      "\e[2K\e[1G\e[J",
      "What letter? \n",
      "\e[32m  1) A\e[0m\n",
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
      "\e[32m  4) D\e[0m\n",
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
end
