# frozen_string_literal: true
# https://adventofcode.com/2019/day/11

require 'pry'
require './boilerplate'
require './intcode'

Direction = Struct.new(:x, :y, :name) do
  def turn(instruction)
    offset =  instruction == Right ? 1 : -1
    current = Directions.index(self)
    Directions[(current + offset) % Directions.length]
  end
  def to_s; "#{name}(#{x}/#{y})"; end
end
North      = Direction.new(0, -1, "North")
East       = Direction.new(1, 0, "East")
South      = Direction.new(0, 1, "South")
West       = Direction.new(-1, 0, "West")
Directions = [North, East, South, West]

Coordinate = Struct.new(:x, :y) do
  def move(facing); Coordinate.new(x + facing.x, y + facing.y); end
  def to_s; "Coordinate(x: #{x}, y: #{y})"; end
end

Black = 0
White = 1
Left  = 0
Right = 1

class Painter < Boilerstate
  attr_accessor :instructions, :painted, :location, :facing
  def parse(input)
    @location    = Coordinate.new(0, 0)
    @facing      = North
    @painted     = {}
    @robot       = Intcode.new(input, block_on_output: true)

    @painted[@location] = White if @options[:start_on_white]
  end

  def color_at(coordinate); @painted[coordinate] || Black; end
  def squares_painted; @painted.length; end

  def paint
    while(!@robot.halted)
      instructions = [@robot.run(color_at(@location)), @robot.run]
      break if @robot.halted
      log "current location: #{@location}, facing: #{@facing}, color: #{color_at(@location)}, instructions: #{instructions}" 

      @painted[location] = instructions[0]
      @facing = @facing.turn(instructions[1])
      @location = @location.move(@facing)
    end
    self
  end

  def stringify
    paint
    keys     = @painted.keys
    sorted_x = keys.sort_by(&:x)
    sorted_y = keys.sort_by(&:y)
    out      = ""

    (sorted_y.first.y..sorted_y.last.y).each do |y|
      (sorted_x.first.x..sorted_x.last.x).each do |x|
        out = out + (@painted[Coordinate.new(x, y)] == White ? '■' : ' ')
      end
      out = out + "\n"
    end
    out
  end
end


part 1 do
  assert_call_on(North, East, :turn, Right)
  assert_call_on(North, West, :turn, Left)
  assert_call_on(Painter.new(input, logging: false).paint, 2276, :squares_painted)
end

part 2 do
  painter = Painter.new(input, start_on_white: true)
  puts painter.stringify
end
