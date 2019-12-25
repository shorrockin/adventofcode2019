# frozen_string_literal: true
# https://adventofcode.com/2019/day/24

require 'pry'
require './boilerplate'
require './coordinates'
require 'set'

EMPTY_SYMBOL = '.'.white.bold
BUG_SYMBOL   = '#'.green.bold

def biodiversity(grid)
  grid.select(:bug, true).reduce(0) do |sum, coord|
    sum + (2 ** (coord.x + (coord.y * grid.width)))
  end
end

def to_grid(lines)
  Flat::Grid.from_lines(lines) do |char, x, y|
    case char
    when '.' then {symbol: EMPTY_SYMBOL, bug: false, proximity: 0}
    else; {symbol: BUG_SYMBOL, bug: true, proximity: 0}
    end
  end
end

def evolve(grid, times = 1)
  times.times.each do 
    # reset the proximity on the grid
    grid.points.each {|coord, data| grid.set(coord, :proximity, 0)}

    # go through all bugs, increment proximity of all their neighbors by one
    grid.select(:bug, true).each do |coord|
      grid.neighbors(coord).each do |neighbor_coord| 
        grid.set(neighbor_coord, :proximity, grid.get(neighbor_coord, :proximity) + 1)
      end
    end

    grid.points.each do |coord, data|
      if (data[:bug] && data[:proximity] != 1)
        data[:bug] = false 
      elsif (!data[:bug] && (data[:proximity] == 1 || data[:proximity] == 2))
        data[:bug] = true
      end

      data[:proximity] = 0 # need to reset otherwise hashes don't computer properly for equality
      data[:symbol] = data[:bug] ? BUG_SYMBOL : EMPTY_SYMBOL
    end
  end

  grid
end

def biodiversity_at_loop(grid)
  previous = Set.new

  while(true)
    break if previous.include?(grid.hash)
    previous.add(grid.hash)
    evolve(grid)
  end

  biodiversity(grid)
end

class RecursiveGrid < ThreeD::Grid
  attr_accessor :width, :height, :center

  def initialize(grid, width, height)
    super()
    @width = width
    @height = height
    @center = Flat::Coordinate.new(@width / 2, @height / 2)
    grid.select(:bug, true).each do |coord|
      add(coord.x, coord.y, 0, {symbol: BUG_SYMBOL, bug: true})
    end
  end

  def at(coordinate)
    # make sure we're within valid bounds
    return nil if (coordinate.x < 0 || coordinate.y < 0)
    return nil if (coordinate.y >= @height || coordinate.x >= @width)
    return nil if (coordinate.x == @center.x && coordinate.y == @center.y)

    # lazy retrieval / initialization otherwise
    @points[coordinate] ||= {symbol: EMPTY_SYMBOL, bug: false, proximity: 0}
  end

  def neighbors(coordinate, filter_prop = nil, filter_value = nil)
    all_neighbors = super(coordinate, filter_prop, filter_value)

    if coordinate.x == 0 # left side
      all_neighbors << ThreeD::Coordinate.new(@center.x - 1, @center.y, coordinate.z - 1)
    elsif coordinate.x == @width - 1 # right side
      all_neighbors << ThreeD::Coordinate.new(@center.x + 1, @center.y, coordinate.z - 1)
    end

    if coordinate.y == 0 # top
      all_neighbors << ThreeD::Coordinate.new(@center.x, @center.y - 1, coordinate.z - 1)
    elsif coordinate.y == @height - 1 # bottom
      all_neighbors << ThreeD::Coordinate.new(@center.x, @center.y + 1, coordinate.z - 1)
    end

    if coordinate == ThreeD::Coordinate.new(@center.x - 1, @center.y, coordinate.z) # left of center, add left side
      (0...@height).each do |y|
        all_neighbors << ThreeD::Coordinate.new(0, y, coordinate.z + 1)
      end
    elsif coordinate == ThreeD::Coordinate.new(@center.x + 1, @center.y, coordinate.z) # right of center, add right side
      (0...@height).each do |y|
        all_neighbors << ThreeD::Coordinate.new(@width - 1, y, coordinate.z + 1)
      end
    elsif coordinate == ThreeD::Coordinate.new(@center.x, @center.y - 1, coordinate.z) # above center, add top side
      (0...@width).each do |x|
        all_neighbors << ThreeD::Coordinate.new(x, 0, coordinate.z + 1)
      end
    elsif coordinate == ThreeD::Coordinate.new(@center.x, @center.y + 1, coordinate.z) # below center, add bottom side
      (0...@width).each do |x|
        all_neighbors << ThreeD::Coordinate.new(x, @height - 1, coordinate.z + 1)
      end
    end

    # once we know the flat neighbors we need to check to see if they're on any
    # of the bounds to return recursive neighbors.
    all_neighbors
  end

  def bug_count
    select(:bug, true).length
  end
end

EXAMPLE = [
  '....#',
  '#..#.',
  '#..##',
  '..#..',
  '#....',
]

part 1 do
  assert_call(2129920, :biodiversity_at_loop, to_grid(EXAMPLE))
  assert_call(23967691, :biodiversity_at_loop, to_grid(input))
end

part 2 do
  grid = RecursiveGrid.new(to_grid(EXAMPLE), 5, 5)
  assert_call_on(evolve(grid, 10), 99, :bug_count)

  grid = RecursiveGrid.new(to_grid(input), 5, 5)
  assert_call_on(evolve(grid, 200), 2003, :bug_count)
end
