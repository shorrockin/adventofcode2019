# frozen_string_literal: true

require './coordinates'
require './memoize'
require 'set'

class BFS
  QueueNode = Struct.new(:coordinate, :distance, :path)
  Result = Struct.new(:distance, :path)

  attr_accessor :grid

  def initialize(grid)
    @grid = grid
  end

  def queue_node(from_node, to, distance, path)
    QueueNode.new(to, distance, path + [to])
  end

  def at_to_point?(queue_node, to)
    queue_node.coordinate == to
  end

  def neighbors(queue_node, traversable_prop)
    @grid.neighbors(queue_node.coordinate, traversable_prop, true)
  end

  def visited_record(coordinate, queue_node)
    coordinate
  end

  def shortest_distance(from, to, traversable_prop = :traversable)
    visited = Set.new
    queue   = Queue.new

    # mark all nodes that are not traversable as false
    @grid.select(traversable_prop, false).each {|coordinate| visited.add(visited_record(coordinate, nil)) }
    
    # add the source as the starting element in our queue
    qn = queue_node(nil, from, 0, [])
    queue.push(qn)
    visited.add(visited_record(qn.coordinate, qn))

    # loop until we're out of elements
    while(!queue.empty?)
      node = queue.pop()
      return Result.new(node.distance, node.path) if at_to_point?(node, to)

      neighbors(node, traversable_prop).each do |neighbor|
        qn = queue_node(node, neighbor, node.distance + 1, node.path)
        visited_record = visited_record(qn.coordinate, qn)

        unless visited.include?(visited_record)
          visited.add(visited_record)
          queue.push(qn)
        end
      end
    end

    nil
  end

  def self.shortest_distance(grid, from, to, traversable_prop = :traversable)
    bfs = BFS.new(grid)
    bfs.shortest_distance(from, to, traversable_prop)
  end
end