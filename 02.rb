# frozen_string_literal: true
# https://adventofcode.com/2019/day/2

require 'pry'
require './boilerplate'
require './intcode'

def run_with(noun, verb)
  memory = input.split(',')
  memory[1] = noun
  memory[2] = verb
  
  program = Intcode.new(memory.join(','))
  program.run(nil)
  program
end

def run(instructions)
  program = Intcode.new(instructions)
  program.run(nil)
  program
end

part 1 do
  assert_call_on(run("1,0,0,0,99"), [2,0,0,0,99] , :memory)
  assert_call_on(run("2,3,0,3,99"), [2,3,0,6,99] , :memory)
  assert_call_on(run("2,4,4,5,99,0"), [2,4,4,5,99,9801] , :memory)
  assert_call_on(run("1,1,1,4,99,5,6,0,99"), [30,1,1,4,2,5,6,0,99] , :memory)
  
  log_call_on(run_with(12, 2).memory, :[], 0) # 4576384
end

part 2 do
  expected = 19690720

  # there must be a non-brute force way to achieve this. pattern in the program
  # which is passed in perhaps?
  (0..99).each do |noun|
    (0..99).each do |verb|
      memory = run_with(noun, verb).memory
      if memory[0] == expected 
        puts "  #{'-'.yellow} 100 * #{noun.to_s.green}(noun) + #{verb.to_s.green}(verb) = #{(100 * noun + verb).to_s.green}(answer)"
        return
      end
    end
  end
end
