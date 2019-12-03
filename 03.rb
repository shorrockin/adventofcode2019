# frozen_string_literal: true
# https://adventofcode.com/2019/day/3

require 'pry'
require './boilerplate'

Instruction = Struct.new(:direction, :amount, keyword_init: true)

Coordinate = Struct.new(:x, :y, keyword_init: true) do
  def distance; x.abs + y.abs; end
end

class Solution < Boilerstate
  attr_accessor :path_one
  attr_accessor :path_one_positions
  attr_accessor :path_two
  attr_accessor :path_two_positions
  attr_accessor :intersections

  module Directions
    Right = Coordinate.new(x: 1, y: 0)
    Down  = Coordinate.new(x: 0, y: -1)
    Up    = Coordinate.new(x: 0, y: 1)
    Left  = Coordinate.new(x: -1, y: 0)
    
    def self.for(value)
      case value
      when "R" then Directions::Right
      when "D" then Directions::Down
      when "U" then Directions::Up
      when "L" then Directions::Left
      else; raise "unknown direction value #{value}"
      end
    end
  end

  def parse(input)
    raise "expected two lines" unless input.length == 2

    @path_one           = parse_path(input.first)
    @path_one_positions = path_positions(@path_one)
    @path_two           = parse_path(input.last)
    @path_two_positions = path_positions(@path_two)
    @intersections      = @path_one_positions & @path_two_positions
  end

  def parse_path(line)
    line.split(',').map do |p| 
      Instruction.new(
        direction: Directions.for(p[0]), 
        amount: p[1..p.length].to_i
      )
    end
  end

  def path_positions(path)
    positions = []
    current   = Coordinate.new(x: 0, y: 0)

    path.each do |instruction|
      instruction.amount.times do 
        current = Coordinate.new(x: current.x + instruction.direction.x, y: current.y + instruction.direction.y)
        positions << current
      end
    end

    positions
  end

  def closest_intersection_distance
    @intersections.sort_by(&:distance).first.distance
  end

  def closest_intersection_by_steps
    # the better way to do this would be to check for intersections as we create
    # the path, but this works well enough.
    @intersections.map do |intersection|
      @path_one_positions.index(intersection) + @path_two_positions.index(intersection) + 2
    end.sort.first
  end
end

part "1/2 - Example One" do
  example_one = Solution.new(
    [
      "R8,U5,L5,D3\n",
      "U7,R6,D4,L4"
    ]
  )

  intersections = example_one.intersections
  assert_call_on(intersections, 2, :length)
  assert_call_on(intersections, Coordinate.new(x: 6, y: 5), :first)
  assert_call_on(intersections, Coordinate.new(x: 3, y: 3), :last)
  assert_call_on(example_one, 6, :closest_intersection_distance)
  assert_call_on(example_one, 30, :closest_intersection_by_steps)
end

part "1/2 - Example Two" do
  example_two = Solution.new(
    [
      "R75,D30,R83,U83,L12,D49,R71,U7,L72\n",
      "U62,R66,U55,R34,D71,R55,D58,R83"
    ]
  )

  assert_call_on(example_two.path_one, 9, :length)
  assert_call_on(example_two.path_two, 8, :length)
  assert_call_on(example_two.path_one, Instruction.new(direction: Solution::Directions::Left, amount: 72), :last)
  assert_call_on(example_two.path_two, Instruction.new(direction: Solution::Directions::Up, amount: 62), :first)
  assert_call_on(example_two, 159, :closest_intersection_distance)
  assert_call_on(example_two, 610, :closest_intersection_by_steps)
end

part "1/2 - Example Three" do
  example_three = Solution.new(
    [
      "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51",
      "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"
    ]
  )
  assert_call_on(example_three, 135, :closest_intersection_distance)
  assert_call_on(example_three, 410, :closest_intersection_by_steps)
end

part "1" do
  log_call_on(Solution.new(input), :closest_intersection_distance) # 316
end

part "2" do
  log_call_on(Solution.new(input), :closest_intersection_by_steps) # 16368
end
