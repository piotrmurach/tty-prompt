# encoding: utf-8

RSpec.describe TTY::Prompt::Question, '#initialize' do

  subject(:question) { described_class.new(TTY::TestPrompt.new)}

  it { expect(question.echo).to eq(true) }

  it { expect(question.mask).to eq(TTY::Prompt::Question::UndefinedSetting) }

  it { expect(question.char).to eq(false) }

  it { expect(question.modifier).to eq([]) }

  it { expect(question.validation).to eq(TTY::Prompt::Question::UndefinedSetting) }
end
