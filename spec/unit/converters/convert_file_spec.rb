# frozen_string_literal: true

RSpec.describe TTY::Prompt::Question, 'convert file' do
  it "converts to file" do
    ::File.write('test.txt', 'foobar')

    prompt = TTY::TestPrompt.new
    prompt.input << "test.txt"
    prompt.input.rewind

    answer = prompt.ask("Which file to open?", convert: :file)

    expect(::File.basename(answer)).to eq('test.txt')
    expect(::File.read(answer)).to eq('foobar')

    ::File.unlink('test.txt') unless Gem.win_platform?
  end
end
