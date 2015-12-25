# encoding: utf-8

RSpec.describe TTY::Prompt::Question, 'convert custom' do

  subject(:prompt) { TTY::TestPrompt.new }

  it 'converts response with custom conversion' do
    prompt.input << "one,two,three\n"
    prompt.input.rewind
    conversion = proc { |input| input.split(/,\s*/) }
    answer = prompt.ask('Ingredients? (comma sep list)', convert: conversion)
    expect(answer).to eq(['one','two','three'])
  end
end
