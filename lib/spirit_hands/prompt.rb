require 'spirit_hands/prompt/main'
require 'spirit_hands/prompt/multiline'

module SpiritHands
  module Prompt
    class << self
      def install!
        ::Pry.config.prompt = Pry::Prompt.new(
          :spirit_hands,
          "The SpritHands prompt",
          [ main, multiline ]
        )
      end
    end # self
  end # Prompt
end # SpiritHands
