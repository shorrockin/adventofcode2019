# frozen_string_literal: true
# https://adventofcode.com/2019/day/20

require 'pry'
require './boilerplate'
require './coordinates'
require './bfs'

START_LABEL = 'AA'
END_LABEL = 'ZZ'

class RecursiveBFS < BFS
  RecursiveQueueNode = Struct.new(:coordinate, :distance, :path, :level)
  VisitedRecord = Struct.new(:coordinate, :level)

  def queue_node(from_node, to, distance, path)
    if from_node.nil? # initial entry
      RecursiveQueueNode.new(to, distance, path + [to], 0)
    elsif @grid.warps[from_node.coordinate] == to # using a warp
      # need to determine if it's inner or outer, outer will always been on
      # the out columns/rows
      RecursiveQueueNode.new(to, distance, path + [to], from_node.level + (outer_warp?(from_node.coordinate) ? -1 : 1))
    else # normal
      RecursiveQueueNode.new(to, distance, path + [to], from_node.level)
    end
  end

  def outer_warp?(coord)
    (coord.x == 2 || coord.y == 2 || coord.x == @grid.width - 3 || coord.y == @grid.height - 3)
  end

  def at_to_point?(queue_node, to)
    queue_node.coordinate == to && queue_node.level == 0
  end

  def visited_record(coordinate, queue_node)
    VisitedRecord.new(coordinate, queue_node.nil? ? 0 : queue_node.level)
  end

  def neighbors(queue_node, traversable_prop)
    super(queue_node, traversable_prop).map do |neighbor|
      # if we're returning a warp and we're at level 0 then only include it if
      # it's an inner warp, we cannot using an outer warp at level 0
      if (@grid.warps[queue_node.coordinate] == neighbor) && queue_node.level == 0 && outer_warp?(queue_node.coordinate)
        nil
      else
        neighbor
      end
    end.compact
  end
end

class WarpGrid < Flat::Grid
  include Flat
  attr_accessor :labels, :start, :finish, :warps

  def neighbors(coordinate, filter_prop, filter_value)
    out = super(coordinate, filter_prop, filter_value)
    out << @warps[coordinate] if @warps.include?(coordinate)
    out
  end

  def after_from_lines
    @labels = {}
    @warps = {}

    @points.keys.select {|coordinate| at(coordinate)[:label] == true}.each do |label_one|
      around = neighbors(label_one, :label_or_floor, true)

      # we care about the labels which have both a floor point and the other
      # label around them
      if around.length == 2 
        floor, label_two = @points[around[0]][:floor] == true ? [around[0], around[1]] : [around[1], around[0]]
        label_name = if floor.move(Directions::North) == label_one || floor.move(Directions::West) == label_one
          "#{@points[label_two][:value]}#{@points[label_one][:value]}"
        else
          "#{@points[label_one][:value]}#{@points[label_two][:value]}"
        end
        @labels[label_name] ||= []
        @labels[label_name] << floor
        set(floor, :symbol, '.'.pink.bold)
      end
    end

    @labels.each do |key, coords|
      @start  = coords[0] if key == START_LABEL
      @finish = coords[0] if key == END_LABEL
      if coords.length == 1
        set(coords.first, :symbol, at(coords.first)[:symbol].white_background) 
      else
        @warps[coords[0]] = coords[1]
        @warps[coords[1]] = coords[0]
      end
    end
  end
end

class Solver < Boilerstate
  include Flat
  attr_accessor :grid, :recursive

  def parse(lines)
    @grid = Grid.from_lines(lines, grid: WarpGrid.new) do |char, x, y|
      case char
      when '#' then {traversable: false, wall: true, symbol: Symbols::Block.teal}
      when '.' then {traversable: true, label_or_floor: true, floor: true, symbol: '.'.white.bold}
      when ' ' then {traversable: false, empty: true, symbol: ' '}
      else; {traversable: false, label_or_floor: true, label: true, symbol: char.green, value: char}
      end
    end
    @recursive = @options[:recursive] == true
  end

  def shortest_distance
    bfs = @options[:recursive] ? RecursiveBFS.new(@grid) : BFS.new(@grid)
    solution = bfs.shortest_distance(@grid.start, @grid.finish)
    solution[:distance]
  end
end

EXAMPLE = ['         A           ','         A           ','  #######.#########  ','  #######.........#  ','  #######.#######.#  ','  #######.#######.#  ','  #######.#######.#  ','  #####  B    ###.#  ','BC...##  C    ###.#  ','  ##.##       ###.#  ','  ##...DE  F  ###.#  ','  #####    G  ###.#  ','  #########.#####.#  ','DE..#######...###.#  ','  #.#########.###.#  ','FG..#########.....#  ','  ###########.#####  ','             Z       ','             Z       ']

part 1 do
  example = Solver.new(EXAMPLE)
  assert_call_on(example, 23, :shortest_distance)
  assert_call_on(Solver.new(input(strip: false)), 690, :shortest_distance)
end

part 2 do
  solver = Solver.new(input(strip: false), recursive: true)
  # puts solver.grid.stringify(column_labels: true, line_labels: true)
  assert_call_on(solver, 7976, :shortest_distance)
end
