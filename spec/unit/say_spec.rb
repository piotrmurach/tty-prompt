# frozen_string_literal: true

RSpec.describe TTY::Prompt, '#say' do

  subject(:prompt) { TTY::TestPrompt.new }

  it 'prints an empty message' do
    prompt.say('')
    expect(prompt.output.string).to eq('')
  end

  context 'with new line' do
    it 'prints a message with newline' do
      prompt.say("Hell yeah!\n")
      expect(prompt.output.string).to eq("Hell yeah!\n")
    end

    it 'prints a message with implicit newline' do
      prompt.say("Hell yeah!\n")
      expect(prompt.output.string).to eq("Hell yeah!\n")
    end

    it 'prints a message with newline within text' do
      prompt.say("Hell\n yeah!")
      expect(prompt.output.string).to eq("Hell\n yeah!\n")
    end

    it 'prints a message with newline within text and blank space' do
      prompt.say("Hell\n yeah! ")
      expect(prompt.output.string).to eq("Hell\n yeah! ")
    end

    it 'prints a message without newline' do
      prompt.say("Hell yeah!", newline: false)
      expect(prompt.output.string).to eq("Hell yeah!")
    end
  end

  context 'with tab or space' do
    it 'prints ' do
      prompt.say("Hell yeah!\t")
      expect(prompt.output.string).to eq("Hell yeah!\t")
    end
  end

  context 'with color' do
    it 'prints message with ansi color' do
      prompt.say('Hell yeah!', color: :green)
      expect(prompt.output.string).to eq("\e[32mHell yeah!\e[0m\n")
    end

    it 'prints message with ansi color without newline' do
      prompt.say('Hell yeah! ', color: :green)
      expect(prompt.output.string).to eq("\e[32mHell yeah! \e[0m")
    end
  end

  context 'without color' do
    it 'prints message without ansi' do
      prompt = TTY::TestPrompt.new(enable_color: false)

      prompt.say('Hell yeah!', color: :green)

      expect(prompt.output.string).to eq("Hell yeah!\n")
    end
  end
end
