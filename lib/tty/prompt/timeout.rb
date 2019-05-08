# frozen_string_literal: true

module TTY
  class Prompt
    class Timeout
      # A class responsible for measuring interval
      #
      # @api private
      def initialize(**options)
        @interval_handler = options.fetch(:interval_handler) { -> {} }
        @running = false
      end

      # Evalute block and time it
      #
      # @api public
      def self.timeout(time, interval, &block)
        (@scheduler ||= new).timeout(time, interval, &block)
      end

      # Evalute block and time it
      #
      # @param [Float] max_time
      #   the time by which to stop
      # @param [Float] interval
      #   the interval time for each tick
      #
      # @api public
      def timeout(max_time, interval, &job)
        @running = true
        input_thread  = Thread.new { job.() }
        timing_thread = measure_intervals(max_time, interval, input_thread)
        [input_thread, timing_thread].each(&:join)
      end

      # Cancel this timeout measurement
      #
      # @api public
      def cancel
        return unless @running
        @running = false
      end

      # Measure intervals and terminate input
      #
      # @api private
      def measure_intervals(max_time, interval, input_thread)
        Thread.new do
          Thread.current.abort_on_exception = true
          begin
            start = time_now
            total = interval

            while @running
              runtime = time_now - start
              delta = max_time - runtime

              if delta <= 0.0
                @running = false
              end

              if delta.round >= 0 && runtime >= total
                total += interval
                @interval_handler.(delta.round)
              end
            end
          ensure
            input_thread.terminate
          end
        end
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
    end # Scheduler
  end # Prompt
end # TTY
