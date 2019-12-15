require './boilerplate'

module Codes
  Add            = 1
  Multiply       = 2
  ReadInput      = 3
  WriteOutput    = 4
  JumpIfTrue     = 5
  JumpIfFalse    = 6
  LessThan       = 7
  Equals         = 8
  OffsetRelative = 9
  Halt           = 99
end

class Intcode < Boilerstate
  attr_accessor :program
  attr_accessor :memory
  attr_accessor :output
  attr_accessor :halted
  attr_accessor :address
  attr_accessor :relative_base
  attr_accessor :reader
  attr_accessor :writer

  def parse(input)
    @halted        = false
    @address       = 0
    @program       = input.split(',').map(&:to_i)
    @memory        = {}
    @reader        = @options[:reader] 
    @writer        = @options[:writer]
    @relative_base = 0
  end

  def run
    if (@halted) # some programs can be restarted after they've been halted
      @halted = false
      @address = 0
    end

    while(@program[@address] != Codes::Halt && !@halted)
      command = @program[@address] % 100
      modes   = (@program[@address] / 100).to_s.chars.map(&:to_i).reverse

      if [Codes::Add, Codes::Multiply, Codes::LessThan, Codes::Equals].include?(command)
        left_param  = read(modes, @address, 0)
        right_param = read(modes, @address, 1)
        set_address = param_index(modes, @address, 2)

        if command == Codes::Add 
          write(set_address, left_param + right_param)
        elsif command == Codes::Multiply 
          write(set_address, left_param * right_param)
        elsif command == Codes::LessThan
          write(set_address, left_param < right_param ? 1 : 0)
        elsif command == Codes::Equals
          write(set_address, left_param == right_param ? 1 : 0)
        else
          raise "unknown command #{command}"
        end
        @address += 4
      elsif command == Codes::ReadInput
        raise "reader not set" if @reader.nil?
        write(param_index(modes, @address, 0), @reader.call)
        @address += 2
      elsif command == Codes::WriteOutput
        raise "writer not set" if @writer.nil?
        @writer.call(read(modes, @address, 0))
        @address += 2
      elsif command == Codes::OffsetRelative
        @relative_base += read(modes, @address, 0)
        @address += 2
      elsif [Codes::JumpIfTrue, Codes::JumpIfFalse].include?(command)
        test_param  = read(modes, @address, 0)
        if command == Codes::JumpIfTrue ? test_param != 0 : test_param == 0
          @address = read(modes, @address, 1)
        else
          @address += 3
        end
      else
        raise "unknown memory opcode (#{@program[@address]} / #{command}) at address #{@address}"
      end
    end

    @relative_base = 0
    @address       = 0
    @halted        = true
  end

  def write(index, value)
    return @program[index] = value if index < @program.length
    raise "memory cannot be negative" if index < 0
    @memory[index] = value
  end

  def read(modes, address, index)
    index = param_index(modes, address, index)
    return @program[index] if index < @program.length
    @memory[index] ||= 0 
  end
  
  def param_index(modes, address, index)
    case param_mode(modes, index) 
    when :position then @program[address + index + 1]
    when :immediate then address + index + 1
    when :relative then @program[address + index + 1] + @relative_base
    else; raise "parameter mode value not supported: #{parameter_mode?(modes, index)}"
    end
  end

  def param_mode(modes, parameter)
    return :immediate if modes[parameter] == 1
    return :relative if modes[parameter] == 2
    :position 
  end
end

