# encoding: utf-8

RSpec.describe TTY::Prompt::Question, '#required' do

  subject(:prompt) { TTY::TestPrompt.new }

  it 'requires value to be present' do
    prompt.input << "Piotr"
    prompt.input.rewind
    prompt.ask('What is your name?') { |q| q.required(true) }
    expect(prompt.output.string).to eq([
      "What is your name? ",
      "\e[1000D\e[K\e[1A",
      "\e[1000D\e[K",
      "What is your name? \e[32mPiotr\e[0m\n"
    ].join)
  end

  it 'requires value to be present with option' do
    prompt.input << "  \nPiotr"
    prompt.input.rewind
    prompt.ask('What is your name?', required: true)
    expect(prompt.output.string).to eq([
      "What is your name? ",
      "\e[1000D\e[K",
      "\e[31m>>\e[0m Value must be provided\e[1A",
      "\e[1000D\e[K",
      "What is your name? ",
      "\e[1000D\e[K\e[1A",
      "\e[1000D\e[K",
      "What is your name? \e[32mPiotr\e[0m\n"
    ].join)
  end

  it "doesn't require value to be present" do
    prompt.input << ''
    prompt.input.rewind
    answer = prompt.ask('What is your name?') { |q| q.required(false) }
    expect(answer).to be_nil
  end

  it "uses required in validation check" do
    prompt.input << "  \n#{__FILE__}\ntest\n"
    prompt.input.rewind
    answer = prompt.ask('File name?') do |q|
      q.required(true)
      q.validate { |v| !::File.exist?(v) }
      q.messages[:required?] = 'File name must not be empty!'
      q.messages[:valid?]   = 'File already exists!'
    end
    expect(prompt.output.string).to eq([
      "File name? ",
       "\e[1000D\e[K",
       "\e[31m>>\e[0m File name must not be empty!",
       "\e[1A\e[1000D\e[K",
      "File name? ",
      "\e[1000D\e[K",
      "\e[31m>>\e[0m File already exists!",
      "\e[1A\e[1000D\e[K",
      "File name? ",
      "\e[1000D\e[K",
      "\e[1A\e[1000D\e[K",
      "File name? \e[32mtest\e[0m\n",
    ].join)
    expect(answer).to eq('test')
  end
end
