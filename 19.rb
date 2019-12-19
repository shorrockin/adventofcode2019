# frozen_string_literal: true
# https://adventofcode.com/2019/day/19

require 'pry'
require './boilerplate'
require './intcode'
require './coordinates'

class Drone 
  include Loggable
  include Flat
  include Intcode

  attr_accessor :intcode, :grid, :controller

  def initialize(input)
    @intcode    = Runner.new(input)
    @grid       = Grid.new
    @controller = Controller.new(@intcode, logging: false)
  end

  def scan(from_x: 0, from_y: 0, to_x: 50, to_y: 50)
    (from_y...to_y).each do |y|
      (from_x...to_x).each {|x| data = scan_at(x, y)}
    end
    grid
  end

  def scan_at(x, y)
    existing = @grid.at(Coordinate.new(x, y))
    return existing unless existing.nil?

    output = @controller.run(x, y)
    @grid.add(x, y, {code: output, symbol: output == 1 ? '#'.green : '.'})
  end
end

part 1 do
  grid = Drone.new(input).scan(to_x: 50, to_y: 50)
  assert_equal(158, grid.select(:code, 1).length, "num_points_affected")
end

part 2 do
  drone   = Drone.new(input)
  current = Flat::Coordinate.new(2, 4) # row 1 and 3 have gaps?
  found   = false
  square  = 99 # -1 to exclude the square we're considering

  while (!found)
    at = drone.scan_at(current.x, current.y)

    # we either found a bottom edge, or we found nothing, if nothing move right,
    # else move down and check again
    if at[:code] == 0
      current = current.move(Flat::Directions::East)
    else
      north_coord = current.move(Flat::Directions::North, square)
      east_coord  = north_coord.move(Flat::Directions::East, square)
      
      # valid coordinates
      if north_coord.x >= 0 && north_coord.y >= 0 && east_coord.x >= 0 && east_coord.y >= 0
        north = drone.scan_at(north_coord.x, north_coord.y)
        east = drone.scan_at(east_coord.x, east_coord.y)

        if north[:code] == 1 && east[:code] == 1
          found = true
          assert_equal(6191165, (north_coord.x * 10000) + north_coord.y, "solution")
        end
      end

      current = current.move(Flat::Directions::South)
    end
  end
end