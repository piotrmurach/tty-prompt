# encoding: utf-8

require 'timers'

module TTY
  class Prompt
    class Timeout
      Error = Class.new(RuntimeError)

      TIMEOUT_HANDLER = proc { |t| t.raise Error, 'timeout expired' }

      def initialize(options = {})
        @timeout_handler  = options.fetch(:timeout_handler) { TIMEOUT_HANDLER }
        @interval_handler = options.fetch(:interval_handler) { proc {} }
        @lock    = Mutex.new
        @running = true
        @timers  = Timers::Group.new
      end

      def self.timeout(time, interval, &block)
        (@scheduler ||= new).timeout(time, interval, &block)
      end

      # Evalute block and time it
      #
      # @param [Float] time
      #   the time by which to stop
      # @param [Float] interval
      #   the interval time for each tick
      #
      # @api public
      def timeout(time, interval, &job)
        @runner = async_run(time, interval)
        job.()
        @runner.join
      end

      def cancel
        return unless @running
        @running = false
      end

      def async_run(time, interval)
        Thread.new do
          Thread.current.abort_on_exception = true
          start = Time.now

          interval_timer = @timers.every(interval) do
            runtime = Time.now - start
            delta = time - runtime
            if delta.round >= 0
              @interval_handler.(delta.round)
            end
          end

          while @running
            @lock.synchronize {
              @timers.wait
              runtime = Time.now - start
              delta = time - runtime

              if delta <= 0.0
                @timeout_handler.(Thread.current)
                break
              end
            }
          end

          interval_timer.cancel
        end
      end
    end # Scheduler
  end # Prompt
end # TTY
