# encoding: utf-8

RSpec.describe TTY::Prompt::Question, '#read_bool' do
  it 'fails to read boolean' do
    prompt = TTY::TestPrompt.new
    prompt.input << 'invalid'
    prompt.input.rewind
    expect {
      prompt.ask("Do you read books?", read: :bool)
    }.to raise_error(Necromancer::ConversionTypeError)
  end

  it "handles default values" do
    prompt = TTY::TestPrompt.new
    prompt.input << "\n"
    prompt.input.rewind
    response = prompt.ask('Do you read books?', read: :bool, default: true)
    expect(response).to eql(true)
    expect(prompt.output.string).to eq('Do you read books? (true) ')
  end

  it "handles default values" do
    prompt = TTY::TestPrompt.new
    prompt.input << "\n"
    prompt.input.rewind
    response = prompt.ask("Do you read books?") { |q|
      q.default true
      q.read :bool
    }
    expect(response).to eq(true)
  end

  it 'reads negative boolean' do
    prompt = TTY::TestPrompt.new
    prompt.input << 'No'
    prompt.input.rewind
    response = prompt.ask('Do you read books?', read: :bool)
    expect(response).to eq(false)
  end

  it 'reads positive boolean' do
    prompt = TTY::TestPrompt.new
    prompt.input << 'Yes'
    prompt.input.rewind
    response = prompt.ask("Do you read books?", read: :bool)
    expect(response).to eq(true)
  end

  it 'reads single positive boolean' do
    prompt = TTY::TestPrompt.new
    prompt.input << 'y'
    prompt.input.rewind
    response = prompt.ask('Do you read books?', read: :bool)
    expect(response).to eq(true)
  end
end
