# encoding: utf-8

RSpec.describe TTY::Prompt::Question do
  subject(:prompt) { TTY::TestPrompt.new}

  it "reads pathname" do
    path = double(:path)
    allow(Pathname).to receive(:new).and_return(path)
    prompt.input << "/path/to/file"
    prompt.input.rewind
    answer = prompt.ask('File location?', read: :path)
    expect(Pathname).to have_received(:new).with(/path\/to\/file/)
    expect(answer).to eql(path)
  end
end
