# frozen_string_literal: true
# https://adventofcode.com/2019/day/21

require 'pry'
require './boilerplate'
require './intcode'

def run(intcode, script, vision = 5)
  intcode    = Intcode::Runner.new(intcode)
  controller = Intcode::ASCIIController.new(intcode)
  vision     = vision
  results = controller.run do |prompt|
    if ['.', '#', '@'].include?(prompt[0])
      puts prompt[0...vision].green + prompt[vision..prompt.length]
      vision += 1 if prompt[0] == '#'
    end
    script + "\n"
  end
  results.to_i
end

part 1 do
  # tl;dr jump if any holes and d is solid ground, uses J 
  # and T both as variables.
  script = <<~springscript
  NOT A J
  NOT B T
  OR T J
  NOT C T
  OR T J
  AND D J
  WALK
  springscript
  assert_call(19354392, :run, input, script) 
end

part 2 do
  script = [ # array so we can represent with comments
    "OR H J",  # J=0 if H is hole
    "NOT C T", # T=1 if C is hole
    "AND T J", # jump if C is hole and H is not hole
    "NOT T T", # T=0 if C is hole
    "OR F T",  # T=0 if C is hole and F is hole
    "NOT T T", # T=1 if C is hole AND F is hole
    "OR T J",  # jump if C is hole and F is hole

    "NOT B T", # T=1 if B is hole
    "OR T J",  # jump if B is hole

    "NOT A T", # T=1 if A is hole
    "OR T J",  # jump if A is hole
    "AND D J", # jump if D is not hole
    "RUN"
  ]
  assert_call(1139528802, :run, input, script.join("\n"), 10) 
end