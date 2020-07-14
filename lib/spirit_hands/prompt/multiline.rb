require 'spirit_hands/prompt/base'

module SpiritHands
  module Prompt
    class << self
      private

      # Wait pry prompt in multiline input
      def multiline
        ->(object, level, pry) do
          s = State.new(object, level, pry, ::SpiritHands.app, true)
          color = ::SpiritHands.color && ::SpiritHands.colored_prompt
          render(s, ::SpiritHands.prompt, color)
        end
      end
    end
  end
end
