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

def shortest_key_collection_path(grid, draw = true)
  Solution.new(grid).shortest_path_distance
end

class Solution
  PathCacheKey   = Struct.new(:from, :to)
  PathCacheValue = Struct.new(:keys_needed, :distance)
  VisitedCache   = Struct.new(:from, :to, :with_keys)

  def initialize(grid)
    @grid    = grid
    @keys    = @grid.select(:key, true)
    @starts  = @grid.select(:start, true)
    @doors   = @grid.select(:door, true)
    @visited = {}
    init_cache
  end

  # going through all the keys, for each one pre-compture the distance to the
  # other keys along with what doors are required for this path, and save to 
  # cache structure.
  def init_cache
    locations = @keys + @starts
    @cache    = {}

    locations.each do |from|
      locations.each do |to|
        next if from == to # we'll never travel to ourself
        next if @starts.include?(to) # we'll never travel to the start, only from it

        result = BFS.shortest_distance(@grid, from, to)
        if result.nil?
          @cache[PathCacheKey.new(from, to)] = nil
        else
          keys_needed = result.path.map {|coord| data = @grid.at(coord); data[:door] ? data[:door_value].downcase : nil }.compact
          @cache[PathCacheKey.new(from, to)] = PathCacheValue.new(keys_needed, result.distance)
        end
      end
    end
  end

  def shortest_path_distance
    @keys.map do |key|
      distance_from(@starts.dup, key, [], @keys - [key])
    end.compact.min
  end

  def distance_from(positions, to, with_keys, remaining)
    # use the first position that can reach the to location, here we're assuming
    # that no two start locations can both reach the destination, we also assume
    # bilndly that we'll get at least one of our start locations which can reach
    # this location.
    from = positions.find {|p| !@cache[PathCacheKey.new(p, to)].nil? }
    from_idx = positions.index(from)

    visited_key = VisitedCache.new(positions.hash, to, with_keys)
    return @visited[visited_key] if @visited.include?(visited_key)

    result = @cache[PathCacheKey.new(from, to)]

    return cache_visited(positions, to, with_keys, nil) if (result.keys_needed - with_keys).any? # we don't have the keys we need
    return cache_visited(positions, to, with_keys, result.distance) unless remaining.any? # we're at the end

    new_positions = positions.dup
    new_positions[from_idx] = to

    remaining = remaining.map do |next_location|
      distance_from(new_positions, next_location, (with_keys + [@grid.at(to)[:key_value]]).sort, remaining - [next_location])
    end.compact

    return cache_visited(positions, to, with_keys, nil) unless remaining.any? # we couldn't find a path for the remaining elements
    cache_visited(positions, to, with_keys, result.distance + remaining.min) # add our result to the remaining distance
  end

  def cache_visited(positions, to, with_keys, result)
    @visited[VisitedCache.new(positions.hash, to, with_keys)] = result
    result
  end
end

EXAMPLE_ONE   = ['#########','#b.....@#','#########']
EXAMPLE_TWO   = ['########################', '#f.D.E.e.C.b.A.@.a.B.c.#', '######################.#', '#d.....................#', '########################']
EXAMPLE_THREE = ['########################', '#...............b.C.D.f#', '#.######################', '#.....@.a.B.c.d.A.e.F.g#','########################']
EXAMPLE_FOUR  = ['#################', '#i.G..c...e..H.p#', '########.########', '#j.A..b...f..D.o#', '########@########', '#k.E..a...g..B.n#', '########.########', '#l.F..d...h..C.m#', '#################']
EXAMPLE_FIVE  = ['########################','#@..............ac.GI.b#', '###d#e#f################', '###A#B#C################', '###g#h#i################', '########################']

part 1 do
  puts "  * Note this will only work for 18.input.txt"
  assert_call(6, :shortest_key_collection_path, parse(EXAMPLE_ONE))
  assert_call(86, :shortest_key_collection_path, parse(EXAMPLE_TWO))
  assert_call(132, :shortest_key_collection_path, parse(EXAMPLE_THREE))
  assert_call(136, :shortest_key_collection_path, parse(EXAMPLE_FOUR))
  assert_call(81, :shortest_key_collection_path, parse(EXAMPLE_FIVE))
  assert_call(4868, :shortest_key_collection_path, parse(input))
end

part 2 do
  puts "  * Note this will only work for 18.p2.input.txt"
  assert_call(1984, :shortest_key_collection_path, parse(input))
end