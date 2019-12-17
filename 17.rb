# frozen_string_literal: true
# https://adventofintcode.com/2019/day/17

require 'pry'
require './boilerplate'
require './intcode'

EMPTY_SQUARE = 46.chr
SCAFFOLDING = 35.chr
NEWLINE = "\n"
UP = "^"
DOWN = "v"
LEFT = "<"
RIGHT = ">"
GRID_INPUT = [EMPTY_SQUARE, SCAFFOLDING, NEWLINE, UP, DOWN, LEFT, RIGHT]

INSTRUCTION_ADDRESS = 1195
CURRENT_INSTRUCTION = 3515
GRID_SIZE = 2035
SCORE_ADDRESS = 438
ROTATE_LEFT = -5
ROTATE_RIGHT = -4

Point = Struct.new(:x, :y) do
  def next; Point.new(x + 1, y); end
  def previous; Point.new(x - 1, y); end
  def newline; Point.new(0, y + 1); end
  def north; Point.new(x, y - 1); end
  def south; Point.new(x, y + 1); end
  def east; Point.new(x + 1, y); end
  def west; Point.new(x - 1, y); end
end

class Scaffolding < Boilerstate
  attr_accessor :width, :height
  attr_accessor :grid
  attr_accessor :current_point

  attr_accessor :messages

  attr_accessor :instructions
  attr_accessor :instructions_ptr

  attr_accessor :started

  def length; @grid.length; end

  def parse(input)
    reset_current_point
    @grid = {}
    @messages = []
    @intcode = Intcode.new(input, writer: method(:on_output), reader: method(:provide_move_instructions))
    @intcode.write(0, 2) if @options[:wakeup]
  end

  def reset_current_point
    @height = -1
    @width = 0
    @current_point = Point.new(0, 0)
  end

  def on_output(output)
    output = output.chr if output < 255

    if output == NEWLINE
      if @grid[@current_point.previous].nil? # we received 2 newlines inta row
        contents = stringify
        puts `clear`
        puts "Dust: #{@intcode.program[SCORE_ADDRESS]}"
        puts contents
        reset_current_point

        if @options[:wakeup] && @started && contents != NEWLINE
          next_val = case read_stdin_char
          when 'a' then ROTATE_LEFT
          when 'e' then ROTATE_RIGHT
          when 'b' then binding.pry
          when 'q' then raise "Quit"
          else; 1; end

          unless next_val.nil?
            @intcode.write(INSTRUCTION_ADDRESS, next_val)
            @intcode.write(CURRENT_INSTRUCTION, 0)
          end
        end
      else
        @current_point = @current_point.newline
      end
    elsif GRID_INPUT.include?(output)
      @grid[@current_point] = output
      @current_point = current_point.next
      @width += 1 if height == 0
      @height = @current_point.y
    else
      messages << output
    end
  end

  def read_at(address)
    @intcode.read([1], address, 0)
  end

  def provide_move_instructions
    @instructions ||= "A,A,A,A,A,A,A,A,A,A\nL,R,L,R,L,R,L,R,L,R\nL,R\nL,R\ny\n".chars
    @instruction_ptr ||= 0
    @started = true if @instructions[@instruction_ptr] == 'y'
    @instruction_ptr += 1
    @instructions[@instruction_ptr - 1].ord
  end

  def run
    @intcode.run
  end

  def stringify
    str = ''
    (0..height).each do |y|
      (0...width).each do |x|
        char = @grid[Point.new(x, y)]

        str += case char
        when SCAFFOLDING then '█'.green
        when EMPTY_SQUARE then '.'
        when '^' then '^'.bold.green
        when '<' then '<'.bold.green
        when 'v' then 'v'.bold.green
        when '>' then '>'.bold.green
        else; raise "unable to map '#{char}' at #{x}/#{y}"
        end
      end
      str += "\n"
    end
    str
  end

  def alignments
    @grid.keys.reduce(0) do |sum, point|
      if @grid[point] == SCAFFOLDING
        if [SCAFFOLDING] == [@grid[point.north], @grid[point.south], @grid[point.east], @grid[point.west]].uniq
          sum += (point.x * point.y)
        end
      end
      sum
    end
  end
end

part 1 do
  scaffolding = Scaffolding.new(input, logging: false)
  scaffolding.run

  assert_call_on(scaffolding, 2035, :length)
  assert_call_on(scaffolding, 7780, :alignments)
end

part 2 do
  scaffolding = Scaffolding.new(input, wakeup: true, logging: true)
  scaffolding.run
  puts scaffolding.messages.join
end
