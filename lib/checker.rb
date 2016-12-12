module Gobstones
  class Checker < Mumukit::Metatest::Checker
    def initialize(options)
      @options = options
    end

    def check_final_board(result, expected)
      actual = result[:finalBoard][:table][:gbb]

      if clean(actual) != clean(expected)
        fail_with status: :check_final_board_failed,
                  result: {
                    initial: result[:initialBoard],
                    expected: result[:extraBoard],
                    actual: result[:finalBoard]
                  }
      end
    end

    # // TODO postconditions que faltan: return, boom

    def render_success_output(result)
      renderer.render_success initial: result[:initialBoard],
                              final: result[:finalBoard]
    end

    def render_error_output(result, error)
      report = error.parse_as_json
      renderer.send "render_error_#{report[:status]}", report[:result]
    end

    private

    def fail_with(error)
      fail JSON.generate(error)
    end

    def renderer
      @renderer ||= Gobstones::HtmlRenderer.new(@options)
    end

    def clean(gbb)
      clean_gbb = gbb.gsub /\r|\n/, ""

      if @options[:check_head_position]
        clean_gbb
      else
        clean_gbb.gsub /head \d+ \d+/, ""
      end
    end
  end
end
