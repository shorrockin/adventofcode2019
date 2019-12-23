require './boilerplate'

module Intcode
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

  class Runner < Boilerstate
    attr_accessor :line
    attr_accessor :reader
    attr_accessor :writer
    attr_accessor :reset_variables
    attr_accessor :program
    attr_accessor :memory
    attr_accessor :halted
    attr_accessor :address
    attr_accessor :relative

    def parse(line)
      @line   = line.split(',').map(&:to_i)
      @reader = @options[:reader]
      @writer = @options[:writer]

      reset(false)
    end

    def reset(block = true)
      if @program.nil?
        @program = @line.dup
      elsif @reset_variables.nil?
        # is this actually better than dupping it? we store what varibalse need
        # to be reset after the first run and use this as an indicator on what
        # to reset on subsequent runs

        @reset_variables = []
        @line.each_with_index do |v, i| 
          @program[i] = v
          @reset_variables << i
        end
      else
        @reset_variables.each do |i|
          @program[i] = @line[i]
        end
      end

      @halted   = false
      @address  = 0
      @memory   = {}
      @relative = 0
    end

    def run
      if (@halted) # some programs can be restarted after they've been halted
        @halted   = false
        @address  = 0
        @relative = 0
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
          @relative += read(modes, @address, 0)
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

        return if @options[:run_once]
      end

      @halted = true
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
      when :relative then @program[address + index + 1] + @relative
      else; raise "parameter mode value not supported: #{parameter_mode?(modes, index)}"
      end
    end

    def param_mode(modes, parameter)
      return :immediate if modes[parameter] == 1
      return :relative if modes[parameter] == 2
      :position 
    end
  end

  # ergonomics for responding to intcode read/writes
  class Controller
    include Loggable

    attr :output_buffer
    attr :results
    attr :reset_each_run
    attr :intcode

    def initialize(intcode, reset_each_run: true, logging: false)
      @output_buffer = []
      @intcode = intcode
      @logging = logging
      @reset_each_run = reset_each_run

      intcode.reader = Proc.new do
        raise "unable to provide contents to intcode, output buffer is empty" if @output_buffer.empty?
        log "[sending] #{@output_buffer.first} from #{@output_buffer}"
        @output_buffer.shift
      end

      intcode.writer = Proc.new do |o|
        log "[received] #{o}"
        @results << o
      end
    end

    def run(*args)
      raise "output buffer was not drained on the last run" unless @output_buffer.empty?

      args.each {|a| @output_buffer << a}
      @results = []

      @intcode.reset if reset_each_run
      @intcode.run

      return results.first if results.length == 1
      results
    end

    def to_s; "Controller<output_buffer:#{@output_buffer}>"; end
  end

  class ASCIIController < Controller
    def initialize(intcode)
      super
      @intcode = intcode
    end

    def run(&on_output)
      @results = []

      intcode.writer = Proc.new do |output|
        output = (output <= 128 ? output.chr : output.to_s)

        if output != "\n"
          @results << output
        elsif 
          response = yield(@results.join)

          @results = []
          response.chars.each do |char|
            @output_buffer << char.ord 
          end
        end
      end
      intcode.run

      @results.join
    end
  end
end



