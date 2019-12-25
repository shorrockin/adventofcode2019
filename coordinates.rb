# frozen_string_literal: true

module Flat
  module Directions
    Direction = Struct.new(:label, :x, :y) do
      def to_s; "Direction<#{label}, x:#{x},y:#{y}>"; end
    end

    North = Direction.new('North', 0, -1)
    South = Direction.new('South', 0, 1)
    East  = Direction.new('East', 1, 0)
    West  = Direction.new('West', -1, 0)
    All   = [North, South, East, West]
  end

  Coordinate = Struct.new(:x, :y) do
    def move(direction, times = 1); Coordinate.new(x + (direction.x * times), y + (direction.y * times)); end
    def distance(other); (other.x - x).abs + (other.y - y).abs; end
    def to_s; "Coordinate<x:#{x},y:#{y}>"; end
  end
  
  class Grid
    attr_accessor :points, :width, :height, :start_x, :start_y, :metadata
    def initialize(width: 0, height: 0, metadata: {})
      @points   = {}
      @width    = 0
      @height   = 0
      @start_x  = nil
      @start_y  = nil
      @metadata = metadata
    end

    def add(x, y, data = {})
      add_coordinate(Coordinate.new(x, y), data)
    end

    def add_coordinate(coordinate, data = {})
      @points[coordinate] = data
      @width  = (coordinate.x + 1) if coordinate.x >= width
      @height = (coordinate.y + 1) if coordinate.y >= height
      @start_x = coordinate.x if @start_x.nil? || coordinate.x < @start_x
      @start_y = coordinate.y if @start_y.nil? || coordinate.y < @start_y
      self
    end

    def contains?(coordinate)
      @points[coordinate].nil?
    end

    def at(coordinate)
      @points[coordinate]
    end

    def hash
      @points.hash
    end

    def neighbors(coordinate, filter_prop = nil, filter_value = nil)
      Directions::All.map do |direction|
        target_coord = coordinate.move(direction)
        target_data = at(target_coord)
        if target_data.nil? || (!filter_prop.nil? && target_data[filter_prop] != filter_value)
          target_coord = nil
        end
        target_coord
      end.compact
    end

    def select(property, value)
      @points.keys.select do |coordinate| 
        if (attribute = at(coordinate))
          attribute[property] == value
        end
      end
    end

    def find(property, value)
      @points.keys.find {|coordinate| at(coordinate)[property] == value}
    end

    def set(coordinate, property, value)
      if (attributes = at(coordinate))
        attributes[property] = value
        attributes
      end
    end

    def get(coordinate, property)
      at(coordinate)[property]
    end

    def after_from_lines; end;

    def stringify(
      symbol: :symbol, 
      filler: nil, 
      labels: false,
      from: Coordinate.new(@start_x, @start_y), 
      to: Coordinate.new(@width, @height)
    )
      line_label_width = (to.y.to_s.length + 2)
      column_label_height = to.x.to_s.length
      header = ''

      if labels
        prefix = ' '.rjust(line_label_width + 1, ' ') 

        column_label_height.times.each do |line|
          header += prefix
          header += (from.x...to.x).map do |x|
            x.to_s.rjust(column_label_height, ' ')[line]
          end.join('')
          header += "\n"
        end
      end

      str = (from.y...to.y).map do |y|
        (from.x...to.x).map do |x|
          data = at(Coordinate.new(x, y))
          raise "grid incomplete at #{x},#{y}" if data.nil? && filler.nil?
          str = data.nil? ? filler : data[symbol]
          str = (y.to_s.rjust(line_label_width, ' ') + ' ' + str) if (labels && x == from.x)
          str
        end.join('')
      end.join("\n")

      header + str
    end

    def self.from_lines(lines, grid: Grid.new, &blk)
      lines.each_with_index do |line, y|
        line.chars.each_with_index do |char, x|
          data = yield char, x, y
          grid.add(x, y, data) unless data[:ignore]
        end
      end
      grid.after_from_lines
      grid
    end
  end
end

module ThreeD
  Coordinate = Struct.new(:x, :y, :z) do
    def move(direction, times = 1); Coordinate.new(x + (direction.x * times), y + (direction.y * times), z); end
    def to_s; "Coordinate<x:#{x},y:#{y},#{z}"; end
  end

  class Grid < Flat::Grid
    attr_accessor :points

    def initialize
      super
    end

    def add(x, y, z, data = {})
      add_coordinate(Coordinate.new(x, y, z), data)
    end
  end
end