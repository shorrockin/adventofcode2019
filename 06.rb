# frozen_string_literal: true
# https://adventofcode.com/2019/day/6

require 'pry'
require './boilerplate'

class Planet
  attr_accessor :name, :parent, :children

  def initialize(name) 
    @name     = name
    @children = []
  end

  def orbits
    parent.nil? ? 0 : parent.orbits + 1
  end

  def parent?(planet)
    parent.nil? ? false : (parent == planet || parent.parent?(planet))
  end

  def distance_to(planet)
    raise "no parent, unable to calculate distance" if parent.nil?
    planet == parent ? 0 : 1 + parent.distance_to(planet)
  end
end

class Universe
  attr_accessor :planets

  def initialize
    @planets = {}
    @planets["COM"] = Planet.new("COM")
  end

  def planet(name, parent: nil)
    @planets[name] ||= Planet.new(name)
    unless parent.nil?
      @planets[name].parent = parent 
      parent.children << @planets[name]
    end
    @planets[name]
  end

  def orbits
    @planets.values.reduce(0) {|sum, p| sum + p.orbits}
  end

  def min_distance(from_name, to_name)
    from = @planets[from_name]
    to   = @planets[to_name]

    @planets.values.reduce(nil) do |min, planet|
      if from.parent?(planet) && to.parent?(planet)
        distance = from.distance_to(planet) + to.distance_to(planet)
        min.nil? || min > distance ? distance : min
      else
        min
      end
    end
  end
end

def parse(orbits)
  universe = Universe.new()
  orbits.map {|o| o.split(')').map(&:strip)}.each do |o| 
    universe.planet(o[1], parent: universe.planet(o[0]))
  end
  universe
end

part 1 do
  example = parse(["COM)B\n", "B)C\n", "E)F\n", "B)G\n", "G)H\n", "D)E\n", "D)I\n", "E)J\n", "J)K\n", "K)L\n", "C)D\n"])
  assert_call_on(example.planets, 12, :length)
  assert_call_on(example.planet('C').parent, 'B', :name)
  assert_call_on(example.planet('C').children, 1, :length)
  assert_call_on(example.planet('C').children.first, 'D', :name)
  assert_call_on(example.planet('D'), 3, :orbits)
  assert_call_on(example.planet('L'), 7, :orbits)
  assert_call_on(example.planet('COM'), 0, :orbits)
  assert_call_on(example, 42, :orbits)
  log_call_on(parse(input), :orbits)  # 402879
end

part 2 do
  example = parse(['COM)B', 'B)C', 'C)D', 'D)E', 'E)F', 'B)G', 'G)H', 'D)I', 'E)J', 'J)K', 'K)L', 'K)YOU', 'I)SAN'])
  assert_call_on(example.planet('SAN'), true, :parent?, example.planet('D'))
  assert_call_on(example.planet('SAN'), true, :parent?, example.planet('I'))
  assert_call_on(example.planet('SAN'), false, :parent?, example.planet('E'))
  assert_call_on(example.planet('SAN'), false, :parent?, example.planet('SAN'))
  assert_call_on(example.planet('SAN'), 1, :distance_to, example.planet('D'))
  assert_call_on(example.planet('YOU'), 3, :distance_to, example.planet('D'))
  assert_call_on(example, 4, :min_distance, 'SAN', 'YOU')
  log_call_on(parse(input), :min_distance, 'SAN', 'YOU') # 484
end
