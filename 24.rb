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
    when '.' then {symbol: EMPTY_SYMBOL, empty: true, proximity: 0}
    else; {symbol: BUG_SYMBOL, bug: true, proximity: 0}
    end
  end
end

def next_evolution(previous_grid)
  previous_grid.points.reduce(Flat::Grid.new()) do |next_grid, (coord, data)|
    neighbors = previous_grid.neighbors(coord, :bug, true)
    if data[:bug] && neighbors.length != 1
      next_grid.add(coord.x, coord.y, {symbol: EMPTY_SYMBOL, empty: true})
    elsif data[:empty] && (neighbors.length == 1 || neighbors.length == 2)
      next_grid.add(coord.x, coord.y, {symbol: BUG_SYMBOL, bug: true})
    else
      next_grid.add(coord.x, coord.y, data)
    end
    next_grid
  end
end

def biodiversity_at_loop(starting_grid)
  previous_grids = Set[starting_grid.hash]
  next_grid      = next_evolution(starting_grid)
  previous_grid  = next_grid

  while(!previous_grids.include?(next_grid.hash))
    previous_grids.add(previous_grid.hash)
    previous_grid = next_grid
    next_grid     = next_evolution(previous_grid)
  end

  biodiversity(next_grid)
end

class RecursiveGrid < ThreeD::Grid
  attr_accessor :width, :height, :center

  def initialize(width, height)
    super()
    @center = Flat::Coordinate.new(@width / 2, @height / 2)
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
  grid = to_grid(input).select(:bug, true).reduce(RecursiveGrid.new(5, 5)) do |grid, coord|
    grid.add(coord.x, coord.y, 0, {symbol: BUG_SYMBOL, bug: true})
  end
  binding.pry
end
