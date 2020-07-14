require 'pry'

class << SpiritHands
  # This modifies pry to play our tune
  def melody!(app = nil)
    return false if @installed
    @installed = true

    Pry.config.should_load_plugins = false
    SpiritHands.app = app unless app.nil?
    setup_less_colorize
    setup_less_show_raw_unicode
    setup_hirb
    disable_remote
    setup_nav
    setup_byebug
    setup_doc

    # Use amazing_print for output, but keep pry's pager. If Hirb is
    # enabled, try printing with it first.
    ::SpiritHands::Print.install!

    # Friendlier prompt - line number, app name, nesting levels look like
    # directory paths.
    #
    # Configuration (like Pry.color) can be changed later or even during console usage.
    ::SpiritHands::Prompt.install!
  end

private

  def setup_nav
    return if Pry.plugins['nav'].is_a? Pry::PluginManager::NoPlugin
    require 'pry-nav'
    if jruby?
      Pry.plugins['nav'].activate!
    else
      Pry.plugins['nav'].disable!
    end
  rescue LoadError
  end

  def setup_byebug
    return if Pry.plugins['byebug'].is_a? Pry::PluginManager::NoPlugin
    require 'pry-byebug'
    if jruby?
      Pry.plugins['byebug'].disable!
    else
      Pry.plugins['byebug'].activate!
    end
  rescue LoadError
  end

  def setup_doc
    require 'pry-doc'
    Pry.plugins['doc'].activate!
  end

  def disable_remote
    return if Pry.plugins['remote'].is_a? Pry::PluginManager::NoPlugin
    Pry.plugins['remote'].disable!
  end

  def jruby?
    RUBY_ENGINE == 'jruby'
  end
end # SpiritHands.self
