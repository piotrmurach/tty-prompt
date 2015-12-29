# encoding: utf-8

require 'spec_helper'

RSpec.describe TTY::Prompt::Question, 'convert path' do
  subject(:prompt) { TTY::TestPrompt.new }

  it "converts pathname" do
    path = double(:path)
    allow(Pathname).to receive(:new).and_return(path)
    prompt.input << "/path/to/file"
    prompt.input.rewind
    answer = prompt.ask('File location?', convert: :path)
    expect(answer).to eql(path)
    expect(Pathname).to have_received(:new).with(/path\/to\/file/)
  end
end
