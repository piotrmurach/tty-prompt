# frozen_string_literal: true

RSpec.describe TTY::Prompt::Timer do
  it "times out loop execution" do
    timer = TTY::Prompt::Timer.new(0.03, 0.01)

    yielded = []

    timer.while_remaining do |remaining|
      yielded << remaining
      sleep(0.01)
    end

    expect(yielded).to match_array([
      be_within(0.01).of(0.03),
      be_within(0.01).of(0.02),
      be_within(0.01).of(0.01)
    ])
  end
end
