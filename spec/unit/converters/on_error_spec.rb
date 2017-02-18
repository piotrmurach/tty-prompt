# encoding: utf-8

RSpec.describe TTY::Prompt::Converters do
  it "enforces block argument" do
    expect {
      TTY::Prompt::Converters.on_error
    }.to raise_error(ArgumentError, 'You need to provide a block argument.')
  end
end
