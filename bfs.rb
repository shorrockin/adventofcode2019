# frozen_string_literal: true

require './coordinates'
require './memoize'
require 'set'

module BFS
  QueueNode = Struct.new(:coordinate, :distance, :path)
  Result = Struct.new(:distance, :path)

  def self.shortest_distance(grid, from, to, traversable_prop = :traversable)
    visited = Set[from]
    queue = Queue.new

    # mark all nodes that are not traversable as false
    grid.select(traversable_prop, false).each {|coordinate| visited.add(coordinate) }
    
    # add the source as the starting element in our queue
    queue.push(QueueNode.new(from, 0, [from]))

    # loop until we're out of elements
    while(!queue.empty?)
      node = queue.pop()
      return Result.new(node.distance, node.path) if node.coordinate == to

      grid.neighbors(node.coordinate, traversable_prop, true).each do |neighbor|
        unless visited.include?(neighbor)
          visited.add(neighbor)
          queue.push(QueueNode.new(neighbor, node.distance + 1, node.path + [neighbor]))
        end
      end
    end

    nil
  end
end