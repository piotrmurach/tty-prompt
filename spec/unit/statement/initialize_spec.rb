# encoding: utf-8

require 'spec_helper'

RSpec.describe TTY::Prompt::Statement, '#new' do
  let(:input)  { StringIO.new }
  let(:output) { StringIO.new }
  let(:shell) { TTY::Prompt.new(input, output) }

  it "forces newline after the prompt message" do
    statement = described_class.new
    expect(statement.newline).to eq(true)
  end

  it "displays prompt message in color" do
    statement = described_class.new
    expect(statement.color).to eq(false)
  end
end
