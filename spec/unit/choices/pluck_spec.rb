# encoding: utf-8

RSpec.describe TTY::Prompt::Choices, '.pluck' do
  it "plucks choice from collection by name" do
    collection = %w(large medium small)
    choices = described_class[*collection]
    expect(choices.pluck('medium').name).to eq('medium')
  end
end
