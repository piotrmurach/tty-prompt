# encoding: utf-8

RSpec.describe TTY::Prompt::Choices, '#pluck' do
  it "plucks choice by key name" do
    collection = [{name: 'large'},{name: 'medium'},{name: 'small'}]
    choices = described_class[*collection]
    expect(choices.pluck(:name)).to eq(['large', 'medium', 'small'])
  end
end
