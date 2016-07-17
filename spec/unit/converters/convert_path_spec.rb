# encoding: utf-8

RSpec.describe TTY::Prompt::Question, 'convert path' do
  subject(:prompt) { TTY::TestPrompt.new }

  it "converts pathname" do
    path = double(:path)
    prompt.input << "/path/to/file"
    prompt.input.rewind

    allow(Pathname).to receive(:new).and_return(path)
    expect(Pathname).to receive(:new).with(/path\/to\/file/)

    answer = prompt.ask('File location?', convert: :path)

    expect(answer).to eql(path)
  end
end
