require "base64"

module Gobstones
  class HtmlRenderer
    def initialize(options)
      @options = options
      @polymer_code = encode_board_html "polymer"
      @board_code = encode_board_html "gs-board"
    end

    def render_success(result)
      bind_result boards: prepare_boards([:initial, :final], result),
                  reason: prepare_reason(result[:reason])
    end

    def render_error_check_final_board_failed_different_boards(result)
      bind_result error: :check_final_board_failed_different_boards,
                  boards: prepare_boards([:initial, :expected, :actual], result)
    end

    def render_error_check_failed_unexpected_boom(result)
      bind_result error: :check_failed_unexpected_boom,
                  boards: prepare_boards([:initial, :expected, :actual], result),
                  reason: prepare_reason(result[:reason])
    end

    def render_error_check_error_failed_expected_boom(result)
      bind_result error: :check_error_failed_expected_boom,
                  boards: prepare_boards([:initial, :expected, :final], result)
    end

    def render_error_check_return_failed_no_return(result)
      bind_result error: :check_return_failed_no_return,
                  expected_value: result[:expected_value]
    end

    def render_error_check_return_failed_different_values(result)
      bind_result error: :check_return_failed_different_values,
                  expected_value: result[:expected_value],
                  actual_value: result[:actual_value]
    end

    def render_error_check_error_failed_another_reason(result)
      bind_result error: :check_error_failed_another_reason,
                  expected_code: I18n.t("code_#{result[:expected_code]}"),
                  reason: prepare_reason(result[:reason])
    end

    private

    def prepare_reason(reason)
      return if !reason
      Gobstones::build_error(reason)
    end

    def prepare_boards(names, result)
      visible_names(names, result).map do |it|
        struct title: "#{it}_board".to_sym,
               board: visible_board(result, it)
      end
    end

    def visible_names(names, result)
      names.reject do |it|
        must_show = @options["show_#{it}_board".to_sym]
        !must_show.nil? && !must_show
      end
    end

    def visible_board(result, name)
      board = result[name]

      if board == 'boom'
        HtmlBoard.new(result[:initial], boom: true)
      else
        HtmlBoard.new(board)
      end
    end

    def encode_board_html(file_name)
      Base64.strict_encode64 File.read("bower_components/gs-board/dist/#{file_name}.html")
    end

    def bind_result(result)
      @result = { boards: [] }.merge result
      template_file.result binding
    end

    def template_file
      ERB.new File.read("#{__dir__}/boards.html.erb")
    end
  end
end