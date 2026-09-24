# Do this to use SpiritHands outside Rails
#
#      # .pryrc
#      require 'spirit_hands'
#      # ...
#
#
require 'spirit_hands/options'
require 'spirit_hands/print'
require 'spirit_hands/prompt'
require 'spirit_hands/terminal'
require 'spirit_hands/version'
require 'spirit_hands/melody'
if defined? ::Rails
  require 'pry-rails'
  require 'spirit_hands/railtie'
else
  SpiritHands.melody!
end
