# encoding: utf-8

RSpec.describe TTY::Prompt, '#expand' do

  subject(:prompt) { TTY::TestPrompt.new }

  let(:choices) {
    [{
      key: 'y',
      name: 'Overwrite',
      value: :yes
    }, {
      key: 'n',
      name: 'Skip',
      value: :no
    }, {
      key: 'a',
      name: 'Overwrite all',
      value: :all
    }, {
      key: 'd',
      name: 'Show diff',
      value: :diff
    }, {
      key: 'q',
      name: 'Quit',
      value: :quit
    }]
  }

  it "expands default option" do
    prompt.input << "\n"
    prompt.input.rewind

    result = prompt.expand('Overwrite Gemfile?', choices)
    expect(result).to eq(:yes)

    expect(prompt.output.string).to eq([
      "Overwrite Gemfile? (enter \"h\" for help) [\e[32my\e[0m,n,a,d,q,h] ",
      "\e[2K\e[1G",
      "Overwrite Gemfile? \e[32mOverwrite\e[0m\n"
    ].join)
  end

  it "changes default option" do
    prompt.input << "\n"
    prompt.input.rewind

    result = prompt.expand('Overwrite Gemfile?', choices, default: 3)
    expect(result).to eq(:all)

    expect(prompt.output.string).to eq([
      "Overwrite Gemfile? (enter \"h\" for help) [y,n,\e[32ma\e[0m,d,q,h] ",
      "\e[2K\e[1G",
      "Overwrite Gemfile? \e[32mOverwrite all\e[0m\n"
    ].join)
  end

  it "expands chosen option with extra information" do
    prompt.input << "a\n"
    prompt.input.rewind

    result = prompt.expand('Overwrite Gemfile?', choices)
    expect(result).to eq(:all)

    expect(prompt.output.string).to eq([
      "Overwrite Gemfile? (enter \"h\" for help) [\e[32my\e[0m,n,a,d,q,h] ",
      "\e[2K\e[1G",
      "Overwrite Gemfile? (enter \"h\" for help) [y,n,\e[32ma\e[0m,d,q,h] ",
      "a\n",
      "\e[32m>> \e[0mOverwrite all",
      "\e[A\e[1G\e[55C",
      "\e[2K\e[1G",
      "\e[1B",
      "\e[2K\e[1G",
      "\e[A\e[1G",
      "Overwrite Gemfile? \e[32mOverwrite all\e[0m\n"
    ].join)
  end

  it "expands help option and then defaults" do
    prompt.input << "h\nd\n"
    prompt.input.rewind

    result = prompt.expand('Overwrite Gemfile?', choices)
    expect(result).to eq(:diff)

    expect(prompt.output.string).to eq([
      "Overwrite Gemfile? (enter \"h\" for help) [\e[32my\e[0m,n,a,d,q,h] ",
      "\e[2K\e[1G",
      "Overwrite Gemfile? (enter \"h\" for help) [y,n,a,d,q,\e[32mh\e[0m] h\n",
      "\e[32m>> \e[0mprint help",
      "\e[A\e[1G\e[55C",
      "\e[2K\e[1G",
      "\e[1B",
      "\e[2K\e[1G",
      "\e[A\e[1G",
      "Overwrite Gemfile? \n",
      "  y - Overwrite\n",
      "  n - Skip\n",
      "  a - Overwrite all\n",
      "  d - Show diff\n",
      "  q - Quit\n",
      "  h - print help\n",
      "  Choice [y]: ",
      "\e[2K\e[1G\e[1A" * 7,
      "\e[2K\e[1G",
      "Overwrite Gemfile? \n",
      "  y - Overwrite\n",
      "  n - Skip\n",
      "  a - Overwrite all\n",
      "  \e[32md - Show diff\e[0m\n",
      "  q - Quit\n",
      "  h - print help\n",
      "  Choice [y]: d",
      "\e[2K\e[1G\e[1A" * 7,
      "\e[2K\e[1G",
      "Overwrite Gemfile? \e[32mShow diff\e[0m\n",
    ].join)
  end

  it "specifies options through DSL" do
    prompt.input << "\n"
    prompt.input.rewind

    result = prompt.expand('Overwrite Gemfile?') do |q|
      q.default 4

      q.choice key: 'y', name: 'Overwrite',     value: :yes
      q.choice key: 'n', name: 'Skip',          value: :no
      q.choice key: 'a', name: 'Overwrite all', value: :all
      q.choice key: 'd', name: 'Show diff',     value: :diff
      q.choice key: 'q', name: 'Quit',          value: :quit
    end

    expect(result).to eq(:diff)

    expect(prompt.output.string).to eq([
      "Overwrite Gemfile? (enter \"h\" for help) [y,n,a,\e[32md\e[0m,q,h] ",
      "\e[2K\e[1G",
      "Overwrite Gemfile? \e[32mShow diff\e[0m\n"
    ].join)
  end

  it "specifies options through DSL and executes value" do
    prompt.input << "\n"
    prompt.input.rewind

    result = prompt.expand('Overwrite Gemfile?') do |q|
      q.choice key: 'y', name: 'Overwrite'      do :ok end
      q.choice key: 'n', name: 'Skip',          value: :no
      q.choice key: 'a', name: 'Overwrite all', value: :all
      q.choice key: 'd', name: 'Show diff',     value: :diff
      q.choice key: 'q', name: 'Quit',          value: :quit
    end

    expect(result).to eq(:ok)

    expect(prompt.output.string).to eq([
      "Overwrite Gemfile? (enter \"h\" for help) [\e[32my\e[0m,n,a,d,q,h] ",
      "\e[2K\e[1G",
      "Overwrite Gemfile? \e[32mOverwrite\e[0m\n"
    ].join)
  end

  it "fails to expand due to lack of key attribute" do
    choices = [{ name: 'Overwrite', value: :yes }]

    expect {
      prompt.expand('Overwrite Gemfile?', choices)
    }.to raise_error(TTY::Prompt::ConfigurationError, /Choice Overwrite is missing a :key attribute/)
  end

  it "fails to expand due to wrong key length" do
    choices = [{ key: 'long', name: 'Overwrite', value: :yes }]

    expect {
      prompt.expand('Overwrite Gemfile?', choices)
    }.to raise_error(TTY::Prompt::ConfigurationError, /Choice key `long` is more than one character long/)
  end

  it "fails to expand due to reserve key" do
    choices = [{ key: 'h', name: 'Overwrite', value: :yes }]

    expect {
      prompt.expand('Overwrite Gemfile?', choices)
    }.to raise_error(TTY::Prompt::ConfigurationError, /Choice key `h` is reserved for help menu/)
  end

  it "fails to expand due to duplicate key" do
    choices = [{ key: 'y', name: 'Overwrite', value: :yes },
               { key: 'y', name: 'Change', value: :yes }]

    expect {
      prompt.expand('Overwrite Gemfile?', choices)
    }.to raise_error(TTY::Prompt::ConfigurationError, /Choice key `y` is a duplicate/)
  end
end
