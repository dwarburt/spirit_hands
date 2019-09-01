module SpiritHands
  module Prompt
    # <....>
    # <..../>
    # </....>
    #
    class Render
      # <tag> ... </tag>, tag -> inner part of escape codes
      MATCHED_TAG_CODES = {
        'b'             => 1,
        'bold'          => 1,
        'bright'        => 1,
        'strong'        => 1,

        'dark'          => 2,
        'faint'         => 2,

        'i'             => 3,
        'italic'        => 3,
        'em'            => 3,

        'u'             => 4,
        'underline'     => 4,

        'blink'         => 5,  # evil
        'flash'         => 5,

        'rapid-blink'   => 6, # sinister
        'rapid-flash'   => 6,

        'reverse'       => 7,
        'negative'      => 7,
        'inverse'       => 7,

        'concealed'     => 8,

        'strike'        => 9,
        'strikethrough' => 9,

        'black'         => 30,
        'red'           => 31,
        'green'         => 32,
        'yellow'        => 33,
        'blue'          => 34,
        'magenta'       => 35,
        'cyan'          => 36,
        'white'         => 37,

        'bgblack'       => 40,
        'bgred'         => 41,
        'bggreen'       => 42,
        'bgyellow'      => 43,
        'bgblue'        => 44,
        'bgmagenta'     => 45,
        'bgcyan'        => 46,
        'bgwhite'       => 47,
      }

      # <.../>
      SINGLE_TAGS = {
        # <cmd/>: command number
        'cmd' =>
          lambda do |state|
            pry = state.pry
            (pry.respond_to?(:input_ring) ? pry.input_ring : pry.input_array)
              .size
          end,

        # <tgt/>: target string
        'tgt' => ->(state) {
          unless (str = Pry.view_clip(state.object)) == 'main'
            state.level = 0 if state.level < 0
            "(#{'../' * state.level}#{str})"
          else
            ''
          end
        },

        # <app/>: state.app (Object) converted to String
        'app' => ->(state) {
          app = state.app
          if app.class.respond_to?(:module_parent_name) && \
            app.class.module_parent_name.respond_to?(:underscore)
            app.class.module_parent_name.underscore
          elsif app.class.respond_to?(:parent_name) && \
            app.class.parent_name.respond_to?(:underscore)
            app.class.parent_name.underscore
          elsif app
            app.to_s
          else
            ::SpiritHands.app
          end
        },

        # <sep/>: SpiritHands.prompt_separator
        'sep' => ->(_state) {
          ::SpiritHands.prompt_separator
        }
      }

      # Array<String>
      attr_reader :errors

      def errors?
        errors.any?
      end

      # :state   SpiritHands::Prompt::State
      # :prompt  String
      # :color   true or false/nil
      def initialize(state, prompt, color)
        @state = state
        @prompt = prompt
        @color = color
      end

      def to_s
        @errors = []
        @tag_stack = []
        @result = ''
        @color_applied = false
        @in_tag = false

        @prompt.each_char do |c|
          if @in_tag
            tag_char(c)
          else
            nontag_char(c)
          end
        end

        # @tag_stack.any? --> error/s
        @tag_stack.each { |t| errors << "<#{t}>: Missing </#{t}>" }

        (errors?) ? '' : @result
      end

      private

      def tag_char(c)
        case c
        when '/'
          # close: </
          # single <.+/
          @tag_type = (@tag.nil? || @tag.empty?) ? :close : :single
        when '>' # close tag
          @tag.downcase!
          send @tag_type # :start, :close or :single
          @in_tag = false
        else # append to existing tag
          @tag += c
        end
      end

      def nontag_char(c)
        if instance_variable_defined?(:@escape) && @escape
          nontag_escaped_char(c)
        else
          nontag_unescaped_char(c)
        end
      end

      def nontag_escaped_char(c)
        @escape = false
        @result += (@state.multiline) ? ' ' : c
      end

      def nontag_unescaped_char(c)
        case c
        when '\\' # escape next char
          @escape = true
        when '<' # start tag
          @in_tag = true
          @tag_type = :start
          @tag = ''
        else # normal char
          @result += (@state.multiline) ? ' ' : c
        end
      end

      # <...>
      def start
        code = MATCHED_TAG_CODES[@tag]
        if !code
          errors << "Unknown <#{@tag}>"
          return
        end
        @result += esc(code)
        @tag_stack << @tag
      end

      # </...>
      def close
        code = MATCHED_TAG_CODES[@tag]
        if !code
          errors << "Unknown </#{@tag}>"
          return
        end
        idx = @tag_stack.rindex @tag
        if idx.nil?
          errors << "</#{@tag}>: missing start <#{@tag}>"
          return
        end
        # remove the now closed tag from the stack
        @tag_stack.delete_at idx
        # reset and reapply all codes on the @tag_stack
        @result += reset
        @tag_stack.each { |tag| @result += esc(MATCHED_TAG_CODES[tag]) }
      end

      # <.../>
      def single
        f = SINGLE_TAGS[@tag]
        if !f
          errors << "Unknown </#{@tag}>"
          return
        end
        result = f.(@state).to_s

        # blank out all but sep for multiline prompt, vs. main (normal)
        if @state.multiline && @tag != 'sep'
          result = ' ' * result.length
        end
        @result += result
      end

      def reset
        esc(0)
      end

      # convert a code to an actual character
      def esc(code)
        return '' if !@color
        @color_applied = true
        "\001\e[#{code}m\002".freeze
      end
    end # Render
  end # Prompt
end # SpiritHands
