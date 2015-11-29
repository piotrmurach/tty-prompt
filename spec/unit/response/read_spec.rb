# encoding: utf-8

RSpec.describe TTY::Prompt::Question, '#read' do
  context 'with no mask' do
    it 'asks with echo on' do
      prompt = TTY::TestPrompt.new
      prompt.input << "password"
      prompt.input.rewind
      answer = prompt.ask("What is your password?") { |q| q.echo(true) }
      expect(answer).to eql("password")
      expect(prompt.output.string).to eql('What is your password? ')
    end

    it 'asks with echo off' do
      prompt = TTY::TestPrompt.new
      prompt.input << "password"
      prompt.input.rewind
      answer = prompt.ask("What is your password?") { |q| q.echo(false) }
      expect(answer).to eql("password")
      expect(prompt.output.string).to eql('What is your password? ')
    end
  end

  context 'with mask' do
    it 'masks output with character' do
      prompt = TTY::TestPrompt.new
      prompt.input << "password\n"
      prompt.input.rewind
      answer = prompt.ask("What is your password?") { |q| q.mask('*') }
      expect(answer).to eql("password")
      expect(prompt.output.string).to eql('What is your password? ********')
    end

    it 'ignores mask if echo is off' do
      prompt = TTY::TestPrompt.new
      prompt.input << "password"
      prompt.input.rewind
      answer = prompt.ask('What is your password?') do |q|
        q.echo false
        q.mask '*'
      end
      expect(answer).to eql("password")
      expect(prompt.output.string).to eql('What is your password? ')
    end
  end

  context 'with mask and echo as options' do
    it 'asks with options' do
      prompt = TTY::TestPrompt.new
      prompt.input << "password"
      prompt.input.rewind
      answer = prompt.ask("What is your password:", echo: false, mask: '*')
      expect(answer).to eq("password")
    end

    it 'asks with block' do
      prompt = TTY::TestPrompt.new
      prompt.input << "password"
      prompt.input.rewind
      answer = prompt.ask "What is your password:" do |q|
        q.echo  false
        q.mask '*'
      end
      expect(answer).to eq("password")
    end
  end
end
