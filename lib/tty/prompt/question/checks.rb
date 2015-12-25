# encoding: utf-8

module TTY
  class Prompt
    class Question
      module Checks
        # Check if modifications are applicable
        class CheckModifier
          def self.call(question, value)
            if !question.modifier.nil? || question.modifier
              [Modifier.new(question.modifier).apply_to(value)]
            else
              [value]
            end
          end
        end

        # Check if value is within range
        class CheckRange
          def self.call(question, value)
            if !question.in? ||
              (question.in? && question.in.include?(value))
              [value]
            else
              [value, ["Value #{value} is not included in the range #{question.in}"]]
            end
          end
        end

        # Check if input requires validation
        class CheckValidation
          def self.call(question, value)
            if !question.validation? ||
              (question.validation? &&
                Validation.new(question.validation).call(value))
              [value]
            else
              [value, ["Your answer is invalid (must match #{question.validation.inspect})"]]
            end
          end
        end

        # Check if default value provided
        class CheckDefault
          def self.call(question, value)
            if value.nil? && question.default?
              [question.default]
            else
              [value]
            end
          end
        end

        # Check if input is required
        class CheckRequired
          def self.call(question, value)
            if question.required? && !question.default? && value.nil?
              [value, ['No value provided for required']]
            else
              [value]
            end
          end
        end
      end # Checks
    end # Question
  end # Prompt
end # TTY
