# encoding: utf-8

RSpec.describe TTY::Prompt::Question, 'convert bool' do

  subject(:prompt) { TTY::TestPrompt.new}

  it 'fails to convert boolean' do
    prompt.input << 'invalid'
    prompt.input.rewind
    expect {
      prompt.ask("Do you read books?", convert: :bool)
    }.to raise_error(Necromancer::ConversionTypeError)
  end

  it "handles default values" do
    prompt.input << "\n"
    prompt.input.rewind
    response = prompt.ask('Do you read books?', convert: :bool, default: true)
    expect(response).to eql(true)
    expect(prompt.output.string).to eq([
      "Do you read books? \e[90m(Y/n)\e[0m ",
      "\e[1A\e[1000D\e[K",
      "Do you read books? \e[32mtrue\e[0m"
    ].join)
  end

  it "handles default values" do
    prompt.input << "\n"
    prompt.input.rewind
    response = prompt.ask("Do you read books?") { |q|
      q.default true
      q.convert :bool
    }
    expect(response).to eq(true)
  end

  it 'converts negative boolean' do
    prompt.input << 'No'
    prompt.input.rewind
    response = prompt.ask('Do you read books?', convert: :bool)
    expect(response).to eq(false)
  end

  it 'converts positive boolean' do
    prompt.input << 'Yes'
    prompt.input.rewind
    response = prompt.ask("Do you read books?", convert: :bool)
    expect(response).to eq(true)
  end

  it 'converts single positive boolean' do
    prompt.input << 'y'
    prompt.input.rewind
    response = prompt.ask('Do you read books?', convert: :bool)
    expect(response).to eq(true)
  end
end
