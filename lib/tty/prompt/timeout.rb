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
      end

      def self.timeout(secs, interval, &block)
        (@scheduler ||= new).timeout(secs, interval, &block)
      end

      def timeout(secs, interval, &block)
        return block.() if secs.nil? || secs.to_i.zero?
        @lock.synchronize do
          @runner = Thread.new {
            run_in(secs, interval)
          }
        end
        block.()
      end

      def run_in(secs, interval)
        Thread.current.abort_on_exception = true
        start = Time.now

        loop do
          sleep(interval)
          runtime = Time.now - start
          delta = secs - runtime
          @interval_handler.(delta.round)

          if delta < 0.0
            @timeout_handler.(Thread.current)
            break
          end
        end
      end
    end # Scheduler
  end # Prompt
end # TTY
