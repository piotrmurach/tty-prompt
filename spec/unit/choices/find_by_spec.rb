# encoding: utf-8

RSpec.describe TTY::Prompt::Choices, '#find_by' do
  it "finds a matching choice by key name" do
    collection = [{name: 'large'},{name: 'medium'},{name: 'small'}]
    choice = TTY::Prompt::Choice.from(name: 'small')
    choices = described_class[*collection]
    expect(choices.find_by(:name, 'small')).to eq(choice)
  end
end
