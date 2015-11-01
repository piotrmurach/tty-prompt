# encoding: utf-8

require 'spec_helper'

RSpec.describe TTY::Prompt::Question::Modifier, '#letter_case' do
  let(:string) { 'text to modify' }

  it "changes to uppercase" do
    modified = described_class.letter_case(:up, string)
    expect(modified).to eq('TEXT TO MODIFY')
  end

  it "changes to lower case" do
    modified = described_class.letter_case(:down, string)
    expect(modified).to eq('text to modify')
  end

  it "capitalizes text" do
    modified = described_class.letter_case(:capitalize, string)
    expect(modified).to eq('Text to modify')
  end
end
