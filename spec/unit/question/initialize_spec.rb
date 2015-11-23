# encoding: utf-8

require 'spec_helper'

RSpec.describe TTY::Prompt::Question, '#initialize' do
  let(:message) { 'Do you like me?' }

  subject(:question) { described_class.new(TTY::TestPrompt.new)}

  it { expect(question.echo).to eq(true) }

  it { expect(question.mask).to eq(false) }

  it { expect(question.character).to eq(false) }

  it { expect(question.modifier).to be_kind_of(TTY::Prompt::Question::Modifier) }

  it { expect(question.validation).to be_kind_of(TTY::Prompt::Question::Validation) }
end
