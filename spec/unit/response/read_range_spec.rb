# encoding: utf-8

require 'spec_helper'

RSpec.describe TTY::Prompt::Question, '#read_range' do
  let(:input)  { StringIO.new }
  let(:output) { StringIO.new }
  let(:prompt)  { TTY::Prompt.new(input, output) }

  it 'converts with valid range' do
    input << "20-30"
    input.rewind
    response = prompt.ask("Which age group?").read_range

    expect(response).to be_kind_of Range
    expect(response).to eql (20..30)
  end

  it "fails to convert to range" do
    input << "abcd"
    input.rewind
    expect {
      prompt.ask("Which age group?").read_range
    }.to raise_error(Necromancer::ConversionTypeError)
  end
end
