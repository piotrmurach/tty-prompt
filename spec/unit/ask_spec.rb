# frozen_string_literal: true

RSpec.describe TTY::Prompt, '#ask' do

  subject(:prompt) { TTY::TestPrompt.new }

  it 'asks question' do
    prompt.ask('What is your name?')
    expect(prompt.output.string).to eq([
      "What is your name? ",
      "\e[1A\e[2K\e[1G",
      "What is your name? \n"
    ].join)
  end

  it 'asks an empty question ' do
    prompt = TTY::TestPrompt.new
    prompt.input << "\r"
    prompt.input.rewind

    answer = prompt.ask
    expect(answer).to eq(nil)

    expect(prompt.output.string).to eql("\e[2K\e[1G\n\e[1A\e[2K\e[1G\n")
  end

  it "asks an empty question and returns nil if EOF is sent to stdin" do
    prompt = TTY::TestPrompt.new
    prompt.input << nil
    prompt.input.rewind

    answer = prompt.ask('')

    expect(answer).to eql(nil)
    expect(prompt.output.string).to eq("\e[1A\e[2K\e[1G\n")
  end

  it "asks an empty question with prepopulated value" do
    prompt = TTY::TestPrompt.new
    prompt.input << "\n"
    prompt.input.rewind

    answer = prompt.ask value: "yes"

    expect(answer).to eq("yes")
    expect(prompt.output.string).to eq([
      "yes\e[2K\e[1G",
      "yes\n\e[1A\e[2K\e[1G",
      "\e[32myes\e[0m\n"
    ].join)
  end

  it "asks question with prepopulated value" do
    prompt = TTY::TestPrompt.new prefix: "> "
    prompt.input << "\n"
    prompt.input.rewind

    answer = prompt.ask("Say?") do |q|
      q.value "yes"
    end

    expect(answer).to eq("yes")
    expect(prompt.output.string).to eq([
      "> Say? yes\e[2K\e[1G",
      "> Say? yes\n\e[1A\e[2K\e[1G",
      "> Say? \e[32myes\e[0m\n"
    ].join)
  end

  it "asks a question with a prefix [?]" do
    prompt = TTY::TestPrompt.new(prefix: "[?] ")
    prompt.input << "\r"
    prompt.input.rewind
    answer = prompt.ask 'Are you Polish?'
    expect(answer).to eq(nil)
    expect(prompt.output.string).to eq([
      "[?] Are you Polish? ",
      "\e[2K\e[1G[?] Are you Polish? \n",
      "\e[1A\e[2K\e[1G",
      "[?] Are you Polish? \n"
    ].join)
  end

  it 'asks a question with block' do
    prompt.input << ''
    prompt.input.rewind
    answer = prompt.ask "What is your name?" do |q|
      q.default 'Piotr'
    end
    expect(answer).to eq('Piotr')
    expect(prompt.output.string).to eq([
      "What is your name? \e[90m(Piotr)\e[0m ",
      "\e[1A\e[2K\e[1G",
      "What is your name? \e[32mPiotr\e[0m\n"
    ].join)
  end

  it "changes question color" do
    prompt.input << ''
    prompt.input.rewind
    options = {default: 'Piotr', help_color: :red, active_color: :cyan}
    answer = prompt.ask("What is your name?", options)
    expect(answer).to eq('Piotr')
    expect(prompt.output.string).to eq([
      "What is your name? \e[31m(Piotr)\e[0m ",
      "\e[1A\e[2K\e[1G",
      "What is your name? \e[36mPiotr\e[0m\n"
    ].join)
  end

  it "permits empty default parameter" do
    prompt.input << "\r"
    prompt.input.rewind

    answer = prompt.ask("What is your name?", default: '')
    expect(answer).to eq('')
    expect(prompt.output.string).to eq([
      "What is your name? ",
      "\e[2K\e[1GWhat is your name? \n",
      "\e[1A\e[2K\e[1G",
      "What is your name? \n"
    ].join)
  end

  it "permits nil default parameter" do
    prompt.input << "\r"
    prompt.input.rewind

    answer = prompt.ask("What is your name?", default: nil)
    expect(answer).to eq(nil)
    expect(prompt.output.string).to eq([
      "What is your name? ",
      "\e[2K\e[1GWhat is your name? \n",
      "\e[1A\e[2K\e[1G",
      "What is your name? \n"
    ].join)
  end

  it "overwrites global settings" do
    global_settings = {prefix: "[?] ", active_color: :cyan, help_color: :red}
    prompt = TTY::TestPrompt.new(global_settings)

    prompt.input << "Piotr\r"
    prompt.input.rewind
    prompt.ask('What is your name?')

    prompt.input << "Piotr\r"
    prompt.input.rewind
    local_settings = {prefix: ':-) ', active_color: :blue, help_color: :magenta}
    prompt.ask('What is your name?', local_settings)

    expect(prompt.output.string).to eq([
      "[?] What is your name? ",
      "\e[2K\e[1G[?] What is your name? P",
      "\e[2K\e[1G[?] What is your name? Pi",
      "\e[2K\e[1G[?] What is your name? Pio",
      "\e[2K\e[1G[?] What is your name? Piot",
      "\e[2K\e[1G[?] What is your name? Piotr",
      "\e[2K\e[1G[?] What is your name? Piotr\n",
      "\e[1A\e[2K\e[1G",
      "[?] What is your name? \e[36mPiotr\e[0m\n",
      ":-) What is your name? ",
      "\e[2K\e[1G:-) What is your name? P",
      "\e[2K\e[1G:-) What is your name? Pi",
      "\e[2K\e[1G:-) What is your name? Pio",
      "\e[2K\e[1G:-) What is your name? Piot",
      "\e[2K\e[1G:-) What is your name? Piotr",
      "\e[2K\e[1G:-) What is your name? Piotr\n",
      "\e[1A\e[2K\e[1G",
      ":-) What is your name? \e[34mPiotr\e[0m\n"
    ].join)
  end
end
