module SpiritHands
  class << self
    # Alias for Pry.color
    def color
      ::Pry.color
    end

    def color=(v)
      ::Pry.color = v
    end
  end # SpiritHands.self
end
