# frozen_string_literal: true

RSpec.describe TTY::Prompt, '#collect' do

  subject(:prompt) { TTY::TestPrompt.new }

  def collect(&block)
    prompt = subject
    count = 0

    result = prompt.collect do
      while prompt.yes?("continue?")
        instance_eval(&block)
        count += 1
      end
    end

    result[:count] = count
    result
  end

  context "when receiving multiple answers" do
    let(:colors) { %w(red blue yellow) }

    before do
      subject.input << "y\r" + colors.join("\ry\r") + "\rn\r"
      subject.input.rewind
    end

    it "collects as a list if values method used in chain" do
      result = collect { key(:colors).values.ask("color:") }
      expect(result[:count]).to eq(3)
      expect(result[:colors]).to eq(colors)
    end

    it "collects as a list if values method used in chain with block" do
      result = collect do
        key(:colors).values { key(:name).ask("color:") }
      end
      expect(result[:count]).to eq(3)
      expect(result[:colors]).to eq(colors.map { |c| { name: c } })
    end

    context "with multiple keys" do
      let(:colors) { ["red\rblue", "yellow\rgreen"] }
      let(:expected_pairs) do
        colors.map { |s| Hash[%i(hot cold).zip(s.split("\r"))] }
      end

      it "collects into the appropriate keys" do
        result = collect do
          key(:pairs).values do
            key(:hot).ask("color:")
            key(:cold).ask("color:")
          end
        end

        expect(result[:count]).to eq(2)
        expect(result[:pairs]).to eq(expected_pairs)
      end
    end

    it "overrides a non-array key on multiple answers" do
      result = collect { key(:colors).ask("color:") }
      expect(result[:colors]).to eq(colors.last)
      expect(result[:count]).to eq(3)
    end
  end

  it "collects more than one answer" do
    prompt.input << "Piotr\r30\rStreet\rCity\r123\r"
    prompt.input.rewind

    result = prompt.collect do
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
