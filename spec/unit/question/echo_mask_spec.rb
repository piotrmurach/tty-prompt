# encoding: utf-8

RSpec.describe TTY::Prompt::Question, '#read' do

  subject(:prompt) { TTY::TestPrompt.new }

  it 'asks with echo on' do
    prompt.input << "password"
    prompt.input.rewind
    answer = prompt.ask("What is your password?") { |q| q.echo(true) }
    expect(answer).to eql("password")
    expect(prompt.output.string).to eq([
      "What is your password? ",
      "\e[1A\e[1000D\e[K",
      "What is your password? \e[32mpassword\e[0m"
    ].join)
  end

  it 'asks with echo off' do
    prompt.input << "password"
    prompt.input.rewind
    answer = prompt.ask("What is your password?") { |q| q.echo(false) }
    expect(answer).to eql("password")
    expect(prompt.output.string).to eq([
      "What is your password? ",
      "\e[1A\e[1000D\e[K",
      "What is your password? "
    ].join)
  end
end
