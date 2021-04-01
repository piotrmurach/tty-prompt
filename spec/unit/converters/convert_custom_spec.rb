# frozen_string_literal: true

RSpec.describe TTY::Prompt::Question, "convert custom" do
  subject(:prompt) { TTY::Prompt::Test.new }

  it "converts response with custom conversion" do
    prompt.input << "one,two,three\n"
    prompt.input.rewind
    conversion = proc { |input| input.split(/,\s*/) }
    answer = prompt.ask("Ingredients? (comma sep list)", convert: conversion)
    expect(answer).to eq(%w[one two three])
  end
end
