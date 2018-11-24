# frozen_string_literal: true

RSpec.describe TTY::Prompt::Question, '#required' do

  subject(:prompt) { TTY::TestPrompt.new }

  it 'requires value to be present' do
    prompt.input << "Piotr"
    prompt.input.rewind
    prompt.ask('What is your name?') { |q| q.required(true) }
    expect(prompt.output.string).to eq([
      "What is your name? ",
      "\e[2K\e[1GWhat is your name? P",
      "\e[2K\e[1GWhat is your name? Pi",
      "\e[2K\e[1GWhat is your name? Pio",
      "\e[2K\e[1GWhat is your name? Piot",
      "\e[2K\e[1GWhat is your name? Piotr",
      "\e[1A\e[2K\e[1G",
      "What is your name? \e[32mPiotr\e[0m\n"
    ].join)
  end

  it 'requires value to be present with option' do
    prompt.input << "  \nPiotr"
    prompt.input.rewind
    prompt.ask('What is your name?', required: true)
    expect(prompt.output.string).to eq([
      "What is your name? ",
      "\e[2K\e[1GWhat is your name?  ",
      "\e[2K\e[1GWhat is your name?   ",
      "\e[2K\e[1GWhat is your name?   \n",
      "\e[31m>>\e[0m Value must be provided\e[1A",
      "\e[2K\e[1G",
      "What is your name? ",
      "\e[2K\e[1GWhat is your name? P",
      "\e[2K\e[1GWhat is your name? Pi",
      "\e[2K\e[1GWhat is your name? Pio",
      "\e[2K\e[1GWhat is your name? Piot",
      "\e[2K\e[1GWhat is your name? Piotr",
      "\e[2K\e[1G",
      "\e[1A\e[2K\e[1G",
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
    prompt.input << "  \nexists\ntest\n"
    prompt.input.rewind
    answer = prompt.ask('File name?') do |q|
      q.required(true)
      q.validate { |v| !(v =~ /exists/) }
      q.messages[:required?] = 'File name must not be empty!'
      q.messages[:valid?]   = 'File already exists!'
    end
    expect(answer).to eq('test')
    expect(prompt.output.string).to eq([
      "File name? ",
      "\e[2K\e[1GFile name?  ",
      "\e[2K\e[1GFile name?   ",
      "\e[2K\e[1GFile name?   \n",
      "\e[31m>>\e[0m File name must not be empty!",
      "\e[1A\e[2K\e[1G",
      "File name? ",
      "\e[2K\e[1GFile name? e",
      "\e[2K\e[1GFile name? ex",
      "\e[2K\e[1GFile name? exi",
      "\e[2K\e[1GFile name? exis",
      "\e[2K\e[1GFile name? exist",
      "\e[2K\e[1GFile name? exists",
      "\e[2K\e[1GFile name? exists\n",
      "\e[31m>>\e[0m File already exists!",
      "\e[1A\e[2K\e[1G",
      "File name? ",
      "\e[2K\e[1GFile name? t",
      "\e[2K\e[1GFile name? te",
      "\e[2K\e[1GFile name? tes",
      "\e[2K\e[1GFile name? test",
      "\e[2K\e[1GFile name? test\n",
      "\e[2K\e[1G",
      "\e[1A\e[2K\e[1G",
      "File name? \e[32mtest\e[0m\n",
    ].join)
    expect(answer).to eq('test')
  end
end
