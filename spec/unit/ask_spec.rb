# encoding: utf-8

RSpec.describe TTY::Prompt, '#ask' do

  subject(:prompt) { TTY::TestPrompt.new }

  it 'asks question' do
    prompt.ask('What is your name?')
    expect(prompt.output.string).to eql('What is your name? ')
  end

  it 'asks an empty question ' do
    prompt.ask('')
    expect(prompt.output.string).to eql('')
  end

  it 'asks an empty question and returns nil if EOF is sent to stdin' do
    prompt.input << nil
    prompt.input.rewind
    response = prompt.ask('')
    expect(response).to eql(nil)
    expect(prompt.output.string).to eq('')
  end

  it "asks a question with a prefix [?]" do
    prompt = TTY::TestPrompt.new(prefix: "[?] ")
    prompt.input << ''
    prompt.input.rewind
    response = prompt.ask 'Are you Polish?'
    expect(response).to eq(nil)
    expect(prompt.output.string).to eql '[?] Are you Polish? '
  end

  it 'asks a question with block' do
    prompt.input << ''
    prompt.input.rewind
    value = prompt.ask "What is your name?" do |q|
      q.default 'Piotr'
    end
    expect(value).to eq('Piotr')
    expect(prompt.output.string).to eq('What is your name? (Piotr) ')
  end
end
