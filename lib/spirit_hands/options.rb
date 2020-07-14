# encoding: UTF-8
require 'readline'
require 'spirit_hands/mattr_accessor_with_default'
require 'spirit_hands/options/coolline'
require 'spirit_hands/options/color'
require 'spirit_hands/options/less'
require 'spirit_hands/options/hirb'

module SpiritHands
  ### Options ###

  # When printing values, start with this (default: '=> ')
  mattr_accessor_with_default :value_prompt, '=> '

  # Spaces to indent value (default: 2 spaces)
  mattr_accessor_with_default :value_indent, 2

  # Name of the app, which can be displayed to <app/> tag in prompt
  mattr_accessor_with_default :app, -> {
    if defined?(::Rails)
      ::Rails.application
    else
      # Trumpet emoji or pry
      (Terminal.unicode?) ? "\u{1F3BA}" : 'pry'
    end
  }

  # <color>...</color>
  # <bold>...</color>
  # <cmd/>  command number
  # <app/>  SpiritHands.app, which can be String or a Rails Applicatino object
  # <sep/>  SpiritHands.prompt_separator
  #
  # Use \ to escape literal <, so in a Ruby string constant, "\\<"
  #
  mattr_accessor_with_default :prompt,
    '<b>[<cmd/>]</b> <blue><app/></blue><tgt/>  <red><sep/></red>  '

  # Color the prompt?
  #
  # A different setting than Pry.color since some may like colored output, but a
  # plain prompt.
  #
  # Default: 'true' for GNU readline or rb-readline which correctly count line
  # widths with color codes when using \001 and \002 hints. 'false' for
  # libedit-based wrapper (standard on OS X unless ruby is explicitly compiled
  # otherwise).
  mattr_accessor_with_default :colored_prompt, -> { ::Readline::VERSION !~ /EditLine/ }

  # Separator between application name and input in the prompt.
  #
  # Default: right angle quote (chevron) or >
  #
  mattr_accessor_with_default :prompt_separator, -> {
    (Terminal.unicode?) ? "\u{BB}" : '>'
  }

  # Enable or disable AmazingPrint (default: true)
  mattr_accessor_with_default :amazing_print, true

  def self.app_name
    if app.class.respond_to?(:parent_name) && \
       app.class.parent_name.respond_to?(:underscore)
      app.class.parent_name.underscore
    elsif app
      app.to_s
    else
      ::SpiritHands.app
    end
  end

  def self.config
    c = CONFIG_KEYS.map do |k|
      if k == :app
        [k, app.to_s]
      else
        [k, public_send(k)]
      end
    end
    Hash[c]
  end

  CONFIG_KEYS = [
    :app,
    :app_name,
    :amazing_print,
    :color,
    :colored_prompt,
    :coolline,
    :hirb,
    :hirb_unicode,
    :less_colorize,
    :less_show_raw_unicode,
    :prompt,
    :prompt_separator,
    :value_indent,
    :value_prompt,
  ]
end
