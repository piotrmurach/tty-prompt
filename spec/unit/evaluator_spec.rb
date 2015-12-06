# encoding: utf-8

RSpec.describe TTY::Prompt::Evaluator do
  it "checks chained validation procs" do
    question = double(:question)
    evaluator = TTY::Prompt::Evaluator.new(question)

    evaluator.check { |quest, value|
      if value < 21
        [value, ["#{value} is not bigger than 21"]]
      else
        value
      end
    }

    evaluator.check { |quest, value|
      if value < 42
        [value, ["#{value} is not bigger than 42"]]
      else
        value
      end
    }

    answer = evaluator.call(2)
    expect(answer.errors.count).to eq(2)
    expect(answer.value).to eq(2)
    expect(answer.success?).to eq(false)
    expect(answer.failure?).to eq(true)
  end

  it "checks chained validation objects" do
    question = double(:question)
    evaluator = TTY::Prompt::Evaluator.new(question)

    LessThan21 = Class.new do
      def self.call(quest, value)
        if value < 21
          [value, ["#{value} is not bigger than 21"]]
        else
          value
        end
      end
    end

    LessThan42 = Class.new do
      def self.call(quest, value)
        if value < 42
          [value, ["#{value} is not bigger than 42"]]
        else
          value
        end
      end
    end

    evaluator.check(LessThan21)
    evaluator.check(LessThan42)

    answer = evaluator.call(2)
    expect(answer.errors).to match_array([
      "2 is not bigger than 21",
      "2 is not bigger than 42"
    ])
    expect(answer.value).to eq(2)
    expect(answer.success?).to eq(false)
    expect(answer.failure?).to eq(true)
  end
end
