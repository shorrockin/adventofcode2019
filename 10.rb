# frozen_string_literal: true
# https://adventofcode.com/2019/day/10

require 'pry'
require './boilerplate'

Coordinate = Struct.new(:x, :y) do
  def angle(other); Math.atan2(other.x - x, other.y - y); end
  def distance(other); (other.x - x).abs + (other.y - y).abs; end
end

LineOfSight = Struct.new(:angle, :coordinates)

def parse(lines)
  lines.each_with_index.map do |line, y|
    line.chars.each_with_index.map do |char, x|
      Coordinate.new(x, y) if char == '#'
    end
  end.flatten.compact
end

def lines_of_sight(from, others)
  (others - [from]).group_by {|other| from.angle(other) }
end

def sorted_lines_of_sight(from, others)
  lines_of_sight(from, others).map do |key, values|
    LineOfSight.new(key, values.sort_by {|v| from.distance(v) })
  end.sort_by(&:angle).reverse
end

def count_line_of_sight(from, others)
  lines_of_sight(from, others).length
end

def most_line_of_sight(asteroids)
  asteroids.sort_by {|a| count_line_of_sight(a, asteroids)}.last
end

part 1 do
  data = parse([".#..#", ".....", "#####", "....#", "...##"])
  assert_call_on(data, 10, :length)
  assert_call_on(data.first, 1, :x)
  assert_call_on(data.first, 0, :y)
  assert_call_on(data.last, 4, :x)
  assert_call_on(data.last, 4, :y)
  assert_call(7, :count_line_of_sight, data[0], data)
  assert_call(7, :count_line_of_sight, data[data.length - 1], data)
  assert_call(8, :count_line_of_sight, data[data.length - 2], data)
  assert_call(5, :count_line_of_sight, data[6], data)
  assert_call(Coordinate.new(3, 4), :most_line_of_sight, data)
  
  asteroids = parse(input)
  assert_call(Coordinate.new(25, 31), :most_line_of_sight, asteroids)
  assert_call(329, :count_line_of_sight, most_line_of_sight(asteroids), asteroids)
end

part 2 do
  asteroids = parse(input)
  source    = most_line_of_sight(asteroids)
  lines     = sorted_lines_of_sight(source, asteroids)

  count = 0
  while(count < 200)
    index = count % lines.length
    while lines[index].coordinates.length == 0
      index = (index + 1) % lines.length
    end

    line         = lines[index]
    zap          = line.coordinates[0]
    lines[index] = LineOfSight.new(line.angle, line.coordinates[1..line.length])
    puts "  Solution: #{zap.x * 100 + zap.y}" if count == 199

    count += 1
  end

end
