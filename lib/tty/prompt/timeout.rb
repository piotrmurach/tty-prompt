# encoding: utf-8

module TTY
  class Prompt
    class Timeout
      Error = Class.new(RuntimeError)

      TIMEOUT_HANDLER = proc { |t| t.raise Error, 'timeout expired' }

      def initialize(options = {})
        @timeout_handler  = options.fetch(:timeout_handler) { TIMEOUT_HANDLER }
        @interval_handler = options.fetch(:interval_handler) { proc { } }
        @lock = Mutex.new
        @running = true
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
      def timeout(time, interval, &block)
        @runner = async_run(time, interval)
        @running = block.()
        @runner.join
      end

      def async_run(time, interval)
        Thread.new do
          Thread.current.abort_on_exception = true
          start = Time.now

          while @running
            @lock.synchronize {
              sleep(interval)
              runtime = Time.now - start
              delta = time - runtime
              @interval_handler.(delta.round)

              if delta <= 0.0
                @timeout_handler.(Thread.current)
                break
              end
            }
          end
        end
      end
    end # Scheduler
  end # Prompt
end # TTY
