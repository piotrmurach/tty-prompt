# encoding: utf-8

RSpec.describe TTY::Prompt, '#gather' do

  subject(:prompt) { TTY::TestPrompt.new }

  it "gathers more than one answer" do
    prompt.input << "Piotr\r30\rStreet\rCity\r123\r"
    prompt.input.rewind

    result = prompt.gather do
      key(:name).ask('Name?')

      key(:age).ask('Age?', convert: :int)

      key(:address) do
        key(:street).ask('Street?', required: true)
        key(:city).ask('City?')
        key(:zip).ask('Zip?', validate: /\A\d{3}\Z/)
      end
    end

    expect(result).to include({
      name: 'Piotr',
      age: 30,
      address: {
        street: 'Street',
        city: 'City',
        zip: '123'
      }
    })
  end
end
