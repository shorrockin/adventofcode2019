# frozen_string_literal: true
# https://adventofcode.com/2019/day/18

require 'pry'
require './boilerplate'
require './coordinates'
require './bfs'
require './permutations'
require './memoize'

def parse(lines)
  Flat::Grid.from_lines(lines) do |char, x, y|
    case char
    when '#' then {symbol: Symbols::Block.teal, traversable: false}
    when '.' then {symbol: '.', traversable: true}
    when '@' then {symbol: '@'.yellow, traversable: true, start: true}
    else
      if char.upcase == char
        {symbol: char.green, traversable: true, door: true, door_value: char}
      else
        {symbol: char.blue, traversable: true, key: true, key_value: char}
      end
    end
  end
end

def shortest_key_collection_path(grid, draw = false)
  puts grid.stringify if draw
  Solution.new(grid).shortest_path_distance
end

class Solution
  PathCacheKey   = Struct.new(:from, :to)
  PathCacheValue = Struct.new(:keys_needed, :distance)
  VisitedCache   = Struct.new(:from, :to, :with_keys)

  def initialize(grid)
    @grid  = grid
    @keys  = @grid.select(:key, true)
    @start = @grid.find(:start, true)
    @doors = @grid.select(:door, true)
    @visited = {}
    init_cache
  end

  # going through all the keys, for each one pre-compture the distance to the
  # other keys along with what doors are required for this path, and save to 
  # cache structure.
  def init_cache
    locations = @keys + [@start]
    @cache    = {}

    locations.each do |from|
      locations.each do |to|
        next if from == to # we'll never travel to ourself
        next if to == @start # we'll never travel to the start, only from it

        result      = BFS.shortest_distance(@grid, from, to)
        keys_needed = result.path.map {|coord| data = @grid.at(coord); data[:door] ? data[:door_value].downcase : nil }.compact
        @cache[PathCacheKey.new(from, to)] = PathCacheValue.new(keys_needed, result.distance)
      end
    end
  end

  def shortest_path_distance
    @keys.map do |key|
      distance_from(@start, key, [], @keys - [key])
    end.compact.min
  end

  def distance_from(from, to, with_keys, remaining)
    visited_key = VisitedCache.new(from, to, with_keys)
    return @visited[visited_key] if @visited.include?(visited_key)

    result = @cache[PathCacheKey.new(from, to)]

    return cache_visited(from, to, with_keys, nil) if (result.keys_needed - with_keys).any? # we don't have the keys we need
    return cache_visited(from, to, with_keys, result.distance) unless remaining.any?
    
    remaining = remaining.map do |next_location|
      distance_from(to, next_location, (with_keys + [@grid.at(to)[:key_value]]).sort, remaining - [next_location])
    end.compact

    return cache_visited(from, to, with_keys, nil) unless remaining.any?
    cache_visited(from, to, with_keys, result.distance + remaining.min)
  end

  def cache_visited(from, to, with_keys, result)
    @visited[VisitedCache.new(from, to, with_keys)] = result
    result
  end
end

EXAMPLE_ONE   = ['#########','#b.....@#','#########']
EXAMPLE_TWO   = ['########################', '#f.D.E.e.C.b.A.@.a.B.c.#', '######################.#', '#d.....................#', '########################']
EXAMPLE_THREE = ['########################', '#...............b.C.D.f#', '#.######################', '#.....@.a.B.c.d.A.e.F.g#','########################']
EXAMPLE_FOUR  = ['#################', '#i.G..c...e..H.p#', '########.########', '#j.A..b...f..D.o#', '########@########', '#k.E..a...g..B.n#', '########.########', '#l.F..d...h..C.m#', '#################']
EXAMPLE_FIVE  = ['########################','#@..............ac.GI.b#', '###d#e#f################', '###A#B#C################', '###g#h#i################', '########################']

part 1 do
  assert_call(6, :shortest_key_collection_path, parse(EXAMPLE_ONE))
  assert_call(86, :shortest_key_collection_path, parse(EXAMPLE_TWO))
  assert_call(132, :shortest_key_collection_path, parse(EXAMPLE_THREE))
  assert_call(136, :shortest_key_collection_path, parse(EXAMPLE_FOUR))
  assert_call(81, :shortest_key_collection_path, parse(EXAMPLE_FIVE))
  assert_call(4868, :shortest_key_collection_path, parse(input))
end

part 2 do
end