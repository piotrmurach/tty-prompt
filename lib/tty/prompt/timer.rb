# frozen_string_literal: true

module TTY
  class Prompt
    class Timer
      attr_reader :duration

      def initialize(duration, interval)
        @duration = duration
        @interval = interval
        @current = nil
      end

      def start
        return if @current

        @current = time_now
      end

      def stop
        return unless @current

        @current = nil
      end

      def runtime
        time_now - @current
      end

      def while_remaining
        start
        remaining = duration

        if @duration
          while remaining > 0.0
            yield(remaining)
            remaining = duration - runtime
          end
        else
          loop { yield }
        end
      ensure
        stop
      end

      if defined?(Process::CLOCK_MONOTONIC)
        # Object representing current time
        def time_now
          ::Process.clock_gettime(Process::CLOCK_MONOTONIC)
        end
      else
        # Object represeting current time
        def time_now
          ::Time.now
        end
      end
    end # Timer
  end # Prompt
end # TTY
