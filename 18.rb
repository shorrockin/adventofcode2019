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
  s = Solution.new(grid)
  puts grid.stringify if draw

  out = s.shortest_key_collection_path
  out
end

CacheKey = Struct.new(:from, :to)
CacheValue = Struct.new(:distance, :path, :doors)

class Solution
  include RubyMemoized

  attr_accessor :grid, :bfs_cache
  attr_accessor :iterations, :cache_hits, :cache_miss

  def initialize(grid)
    @grid = grid
    @bfs_cache = {}
    @iterations = 0
    @cache_hits = 0
    @cache_miss = 0
  end

  def shortest_key_collection_path
    min_distance = nil
    start_keys   = @grid.select(:key, true) 
    permutations = Permutations.new(start_keys) 

    while(keys = permutations.next)
      @iterations  += 1
      distance      = 0
      last_location = @grid.find(:start, true)
      valid         = true
      open_doors    = []

      keys.each_with_index do |key, key_index|
        result = cached_shortest_distance(last_location, key, open_doors)
        if result.nil? || (!min_distance.nil? && (result.distance + distance) >= min_distance)
          # if we can't get to this key, then skip over anything else trying to
          # get to this key
          permutations.next_increment_at = key_index
          valid = false
          break
        end

        distance     += result.distance
        last_location = key
        open_doors   << door_for_key(key)
      end

      open_doors = []

      if valid && (min_distance.nil? || distance < min_distance)
        min_distance = distance
      end
    end

    min_distance
  end

  def door_for_key(key)
    key_attributes = @grid.at(key)
    @grid.find(:door_value, key_attributes[:key_value].upcase)
  end

  def cached_shortest_distance(from, to, open_doors)
    cache_key = CacheKey.new(from, to)

    result = if @bfs_cache.include?(cache_key)
      @cache_hits += 1  
      @bfs_cache[cache_key] 
    else
      @cache_miss += 1
      bfs = BFS.shortest_distance(@grid, from, to)
      raise "could not calculate path betwen #{from}/#{to}" if bfs.nil?

      @bfs_cache[cache_key] = CacheValue.new(
        bfs.distance,
        bfs.path,
        bfs.path.select {|coord| @grid.at(coord)[:door] == true }
      )
      @bfs_cache[cache_key]
    end

    return nil if (result.doors - open_doors).any?
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
  assert_call(136, :shortest_key_collection_path, parse(EXAMPLE_FOUR), true)
  assert_call(81, :shortest_key_collection_path, parse(EXAMPLE_FIVE))
  assert_call(123, :shortest_key_collection_path, parse(input))
end

part 2 do
end