# frozen_string_literal: true
# https://adventofcode.com/2019/day/9

require 'pry'
require './boilerplate'
require './intcode'

part 1 do
  assert_call_on(Intcode.new("109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99"), [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99], :run)
  assert_call_on(Intcode.new("1102,34915192,34915192,7,4,7,99,0"), 1219070632396864, :run)
  assert_call_on(Intcode.new("104,1125899906842624,99"), 1125899906842624, :run)
  assert_call_on(Intcode.new(input), 2714716640, :run, 1)
end

part 2 do
  assert_call_on(Intcode.new(input), 58879, :run, 2)
end
