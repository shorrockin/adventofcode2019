require './boilerplate'

module Codes
  Add         = 1
  Multiply    = 2
  ReadInput   = 3
  WriteOutput = 4
  JumpIfTrue  = 5
  JumpIfFalse = 6
  LessThan    = 7
  Equals      = 8
  Halt        = 99
end

class Intcode < Boilerstate
  attr_accessor :memory
  attr_accessor :input, :output

  def parse(input)
    @memory = input.split(',').map(&:to_i)
    @input  = @options[:input] || 1

    address = 0

    while(@memory[address] != Codes::Halt)
      command  = @memory[address] % 100
      modes    = (@memory[address] / 100).to_s.chars.map(&:to_i).reverse

      if [Codes::Add, Codes::Multiply, Codes::LessThan, Codes::Equals].include?(command)
        left_param  = param(modes, address, 0)
        right_param = param(modes, address, 1)
        set_address = @memory[address + 3]

        if command == Codes::Add 
          @memory[set_address] = left_param + right_param
        elsif command == Codes::Multiply 
          @memory[set_address] = left_param * right_param
        elsif command == Codes::LessThan
          @memory[set_address] = left_param < right_param ? 1 : 0
        elsif command == Codes::Equals
          @memory[set_address] = left_param == right_param ? 1 : 0
        else
          raise "unknown command #{command}"
        end
        address += 4
      elsif command == Codes::ReadInput
        @memory[@memory[address + 1]] = @input
        address += 2
      elsif command == Codes::WriteOutput
        @output = param(modes, address, 0)
        address += 2
      elsif [Codes::JumpIfTrue, Codes::JumpIfFalse].include?(command)
        test_param  = param(modes, address, 0)
        if command == Codes::JumpIfTrue ? test_param != 0 : test_param == 0
          address = param(modes, address, 1)
        else
          address += 3
        end
      else
        raise "unknown memory opcode (#{@memory[address]} / #{command}) at address #{address}"
      end
    end
  end

  def param(modes, address, index)
    position_mode?(modes, index) ? @memory[@memory[address + index + 1]] : @memory[address + index + 1]
  end

  def position_mode?(modes, parameter)
    return true if parameter >= modes.length
    return modes[parameter] == 0
  end
end

