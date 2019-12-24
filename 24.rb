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

def evolve(grid)
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
  # grid = to_grid(input).select(:bug, true).reduce(RecursiveGrid.new(5, 5)) do |grid, coord|
  #   grid.add(coord.x, coord.y, 0, {symbol: BUG_SYMBOL, bug: true})
  # end
end
