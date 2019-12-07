# frozen_string_literal: true
# https://adventofcode.com/2019/day/5

require 'pry'
require './boilerplate'
require './intcode'

part 1 do
  log_call_on(Intcode.new(input, input: 1), :output) # 9961446
end

part 2 do
  assert_call_on(Intcode.new("3,9,8,9,10,9,4,9,99,-1,8", input: 8), 1, :output)
  assert_call_on(Intcode.new("3,9,8,9,10,9,4,9,99,-1,8", input: 7), 0, :output)
  log_call_on(Intcode.new(input, input: 5, logging: true), :output) # 742621
end
