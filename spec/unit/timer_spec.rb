# frozen_string_literal: true

RSpec.describe TTY::Prompt::Timer do
  it "times out loop execution" do
    timer = TTY::Prompt::Timer.new(0.03, 0.01)
    yielded = []

    timer.while_remaining do |remaining|
      expect(remaining).to be_within(0.1).of(timer.duration - yielded.size * 0.01)
      yielded << remaining
      sleep(0.01)
    end
  end

  it "registers a tick event" do
    timer = TTY::Prompt::Timer.new(0.03, 0.01)
    yielded = []

    timer.on_tick do |time|
      yielded << time
    end

    timer.while_remaining do
      # busy work
    end

    expect(yielded.size).to be >= 2
  end
end
