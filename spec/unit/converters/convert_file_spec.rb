# encoding: utf-8

RSpec.describe TTY::Prompt::Question, 'convert file' do
  it "converts to file" do
    file = ::File.open('test.txt', 'w')
    file.write('foobar')
    file.close

    prompt = TTY::TestPrompt.new
    prompt.input << "test.txt"
    prompt.input.rewind

    answer = prompt.ask("Which file to open?", convert: :file)

    expect(::File.basename(answer)).to eq('test.txt')
    expect(::File.read(answer)).to eq('foobar')

    ::File.delete(file)
  end
end
