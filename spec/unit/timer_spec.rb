# frozen_string_literal: true

RSpec.describe TTY::Prompt::Timer do
  it "" do
    timer = TTY::Prompt::Timer.new(0.03, 0.01)

    yielded = []

    timer.while_remaining do |remaining|
      sleep(0.01)
      yielded << remaining
    end

    expect(yielded).to match_array([
      be_within(0.01).of(0.03),
      be_within(0.01).of(0.02),
      be_within(0.01).of(0.01)
    ])
  end
end
