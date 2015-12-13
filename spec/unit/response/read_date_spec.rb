# encoding: utf-8

RSpec.describe TTY::Prompt::Question, '#read_date' do
  it 'reads date' do
    prompt = TTY::TestPrompt.new
    prompt.input << "20th April 1887"
    prompt.input.rewind
    response = prompt.ask("When were your born?", read: :date)
    expect(response).to be_kind_of(Date)
    expect(response.day).to eq(20)
    expect(response.month).to eq(4)
    expect(response.year).to eq(1887)
  end

  it "reads datetime" do
    prompt = TTY::TestPrompt.new
    prompt.input << "20th April 1887"
    prompt.input.rewind
    response = prompt.ask("When were your born?", read: :datetime)
    expect(response).to be_kind_of(DateTime)
    expect(response.day).to eq(20)
    expect(response.month).to eq(4)
    expect(response.year).to eq(1887)
  end
end
