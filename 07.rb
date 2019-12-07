# frozen_string_literal: true
# https://adventofcode.com/2019/day/7

require 'pry'
require './boilerplate'
require './intcode'

def amplify(instructions, phases)
  phases.reduce(0) do |last_output, phase|
    program = Intcode.new(instructions)
    program.run([phase, last_output])
  end
end

def max_amplify(instructions, phase_options = [0, 1, 2, 3, 4])
  phase_options.permutation.reduce(0) do |max, phases|
    current = amplify(instructions, phases)
    current > max ? current : max
  end
end

def amplify_with_feedback(instructions, phases)
  programs = phases.map {|p| Intcode.new(instructions, block_on_output: true, initial_inputs: [p])}
  output   = 0
  current  = 0

  while(true)
    output = programs[current].run([output])
    break if programs[current].halted
    current = (current + 1) % programs.length
  end

  programs.last.output
end

def max_amplify_with_feedback(instructions, phase_options = [5, 6, 7, 8, 9])
  phase_options.permutation.reduce(0) do |max, phases|
    current = amplify_with_feedback(instructions, phases)
    current > max ? current : max
  end
end


part 1 do
  assert_call(43210, :amplify, '3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0', [4,3,2,1,0])
  assert_call(54321, :amplify, '3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0', [0,1,2,3,4])
  assert_call(65210, :amplify, '3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0', [1,0,4,3,2])
  log_call(:max_amplify, input) # 225056
end

part 2 do
  assert_call(139629729, :amplify_with_feedback, '3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5', [9,8,7,6,5])
  assert_call(18216, :amplify_with_feedback, '3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10', [9,7,8,5,6])
  log_call(:max_amplify_with_feedback, input) # 14260332
end
