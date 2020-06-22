# frozen_string_literal: true

require "benchmark/ips"

require_relative "../lib/tty/test_prompt"

prompt = TTY::TestPrompt.new

prompt.on(:keypress) do |e|
  prompt.trigger(:keydown) if e.value == "j"
end

100.times do
  prompt.input << " " << "j"
end

prompt.input << "\r"

choices = (1..10_000).to_a

Benchmark.ips do |bench|
  bench.config(time: 10, warmup: 4)

  bench.report("selecting") do
    prompt.input.rewind
    prompt.multi_select("Which number?", choices)
  end
end
