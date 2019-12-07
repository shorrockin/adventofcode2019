# frozen_string_literal: true
# https://adventofcode.com/2019/day/5

require 'pry'
require './boilerplate'
require './intcode'

part 1 do
  log_call_on(Intcode.new(input), :run, 1) # 9961446
end

part 2 do
  assert_call_on(Intcode.new("3,9,8,9,10,9,4,9,99,-1,8"), 1, :run, 8)
  assert_call_on(Intcode.new("3,9,8,9,10,9,4,9,99,-1,8"), 0, :run, 7)
  log_call_on(Intcode.new(input, logging: true), :run, 5) # 742621
end
