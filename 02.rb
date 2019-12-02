# frozen_string_literal: true
# https://adventofcode.com/2019/day/2

require 'pry'
require './boilerplate'

module Codes
  Halt     = 99
  Add      = 1
  Multiply = 2
end

class Intcode < Boilerstate
  attr_accessor :memory

  def parse(input)
    @memory = input.map(&:to_i)
  end

  def run
    address = 0

    while(@memory[address] != Codes::Halt)
      left_address  = @memory[address + 1]
      right_address = @memory[address + 2]
      set_address   = @memory[address + 3]

      if @memory[address] == Codes::Add
        @memory[set_address] = @memory[left_address] + @memory[right_address]
      elsif @memory[address] == Codes::Multiply
        @memory[set_address] = @memory[left_address] * @memory[right_address]
      else
        raise "unknown memory opcode (#{@memory[address]}) at address #{address}"
      end

      address += 4
    end

    @memory
  end
end

def init_memory(noun, verb)
  memory = input.split(',')
  memory[1] = noun
  memory[2] = verb
  memory
end

part 1 do
  assert_call_on(Intcode.new([1,0,0,0,99]), [2,0,0,0,99] , :run)
  assert_call_on(Intcode.new([2,3,0,3,99]), [2,3,0,6,99] , :run)
  assert_call_on(Intcode.new([2,4,4,5,99,0]), [2,4,4,5,99,9801] , :run)
  assert_call_on(Intcode.new([1,1,1,4,99,5,6,0,99]), [30,1,1,4,2,5,6,0,99] , :run)
  log_call_on(Intcode.new(init_memory(12, 2)).run, :[], 0) # 4576384
end

part 2 do
  expected = 19690720

  # there must be a non-brute force way to achieve this. pattern in the program
  # which is passed in perhaps?
  (0..99).each do |noun|
    (0..99).each do |verb|
      memory = Intcode.new(init_memory(noun, verb)).run
      if memory[0] == expected 
        puts "  #{'-'.yellow} 100 * #{noun.to_s.green}(noun) + #{verb.to_s.green}(verb) = #{(100 * noun + verb).to_s.green}(answer)"
        return
      end
    end
  end
end
