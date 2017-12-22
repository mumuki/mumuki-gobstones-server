module Gobstones
  class Checker < Mumukit::Metatest::Checker
    include Gobstones::WithRenderer

    def initialize(options)
      @options = options
    end

    def check_final_board(output, expected)
      status = output[:status]
      result = output[:result]

      assert_not_boom status, result
      actual = result[:finalBoard][:table][:gbb]

      fail_with status: :check_final_board_failed_different_boards,
                result: {
                  initial: result[:initialBoard],
                  expected: result[:extraBoard],
                  actual: result[:finalBoard]
                } if clean(actual) != clean(expected)
    end

    def check_error(output, expected)
      status = output[:status]
      result = output[:result]

      fail_with status: :check_error_failed_expected_boom,
                result: {
                  initial: result[:initialBoard],
                  expected: :boom,
                  final: result[:finalBoard]
                } if status == :passed

      reason_code = convert_known_reason_code result[:finalBoardError][:reason][:code]
      fail_with status: :check_error_failed_another_reason,
                result: {
                  reason: result[:finalBoardError],
                  expected_code: expected
                } if reason_code != expected
    end

    def check_return(output, expected)
      status = output[:status]
      result = output[:result]

      assert_not_boom status, result
      value = result[:finalBoard][:returnValue]

      fail_with status: :check_return_failed_no_return,
                result: {
                  initial: result[:initialBoard],
                  expected_value: expected
                } if value.nil?

      fail_with status: :check_return_failed_different_values,
                result: {
                  initial: result[:initialBoard],
                  expected_value: expected,
                  actual_value: value
                } if value != expected
    end

    private

    def assert_not_boom(status, result)
      fail_with status: :check_failed_unexpected_boom,
                result: {
                  initial: result[:initialBoard],
                  expected: result[:extraBoard],
                  actual: :boom,
                  reason: result[:finalBoardError]
                } if status == :runtime_error
    end

    def fail_with(error)
      fail error.to_json
    end

    def clean(gbb)
      clean_gbb = gbb.gsub /\r|\n| Azul 0| Negro 0| Rojo 0| Verde 0/, ''
      decapitated_gbb = clean_gbb.gsub /head \d+ \d+/, ''

      @options[:check_head_position] ? clean_gbb : decapitated_gbb
    end

    def convert_known_reason_code(code)
      return "no_stones" if code == "cannot-remove-stone"
      return "out_of_board" if code == "cannot-move-to"

      code
    end
  end
end
