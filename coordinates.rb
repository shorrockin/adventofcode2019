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
    attr_accessor :points, :width, :height, :start_x, :start_y
    def initialize
      @points  = {}
      @width   = 0
      @height  = 0
      @start_x = nil
      @start_y = nil
    end

    def add(x, y, data = {})
      point = Coordinate.new(x, y)
      @points[point] = data
      @width  = (point.x + 1) if point.x >= width
      @height = (point.y + 1) if point.y >= height
      @start_x = x if @start_x.nil? || x < @start_x
      @start_y = y if @start_y.nil? || y < @start_y
      data 
    end

    def contains?(coordinate)
      @points[coordinate].nil?
    end

    def at(coordinate)
      @points[coordinate]
    end

    def neighbors(coordinate, filter_prop, filter_value)
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
      @points.keys.select {|coordinate| at(coordinate)[property] == value}
    end

    def find(property, value)
      @points.keys.find {|coordinate| at(coordinate)[property] == value}
    end

    def set(coordinate, property, value)
      attributes = @points[coordinate]
      attributes[property] = value
      attributes
    end

    def after_from_lines; end;

    def stringify(
      symbol: :symbol, 
      filler: nil, 
      line_labels: false, 
      column_labels: false, 
      from: Coordinate.new(@start_x, @start_y), 
      to: Coordinate.new(@width, @height)
    )
      line_label_width = (to.y.to_s.length + 2)
      column_label_height = to.x.to_s.length
      header = ''

      if column_labels
        prefix = ' '.rjust(line_label_width + 1, ' ') if line_labels # adjust for line labels

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
          str = (y.to_s.rjust(line_label_width, ' ') + ' ' + str) if (line_labels && x == from.x)
          str
        end.join('')
      end.join("\n")

      header + str
    end

    def self.from_lines(lines, grid: Grid.new, &blk)
      lines.each_with_index do |line, y|
        line.chars.each_with_index do |char, x|
          data = yield char, x, y
          grid.add(x, y, data)
        end
      end
      grid.after_from_lines
      grid
    end
  end

end