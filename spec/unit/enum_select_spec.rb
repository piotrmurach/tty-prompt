# encoding: utf-8

RSpec.describe TTY::Prompt do

  subject(:prompt) { TTY::TestPrompt.new }

  it "selects default option when return pressed immediately" do
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
      "\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[J",
      "Select an editor? \e[32m/bin/nano\e[0m\n"
    ].join)
  end

  it "selects option by index from the list" do
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
      "\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[J",
      "Select an editor? \n",
      "  1) /bin/nano\n",
      "  2) /usr/bin/vim.basic\n",
      "\e[32m  3) /usr/bin/vim.tiny\e[0m\n",
      "  Choose 1-3 [2]: 3",
      "\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[J",
      "Select an editor? \e[32m/usr/bin/vim.tiny\e[0m\n"
    ].join)
  end

  it "selects option through DSL" do
    prompt.input << "\n"
    prompt.input.rewind
    value = prompt.enum_select("Select an editor?") do |menu|
      menu.default 2

      menu.choice "/bin/nano"
      menu.choice "/usr/bin/vim.basic"
      menu.choice "/usr/bin/vim.tiny"
    end

    expect(value).to eq('/usr/bin/vim.basic')
    expect(prompt.output.string).to eq([
      "Select an editor? \n",
      "  1) /bin/nano\n",
      "\e[32m  2) /usr/bin/vim.basic\e[0m\n",
      "  3) /usr/bin/vim.tiny\n",
      "  Choose 1-3 [2]: ",
      "\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[1A\e[1000D\e[K\e[J",
      "Select an editor? \e[32m/usr/bin/vim.basic\e[0m\n"
    ].join)
  end
end
