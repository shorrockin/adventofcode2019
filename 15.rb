
# frozen_string_literal: true
# https://adventofcode.com/2019/day/15

require 'pry'
require './boilerplate'
require './intcode'

Direction = Struct.new(:description, :value, :x, :y) do
  def reverse; Directions[(Directions.index(self) + 2) % Directions.length]; end
  def next; Directions[(Directions.index(self) + 1) % Directions.length]; end
  def to_s; "#{@description}"; end
end

North      = Direction.new('North', 1, 0, -1)
South      = Direction.new('South', 2, 0, 1)
East       = Direction.new('East', 3, 1, 0)
West       = Direction.new('West', 4, -1, 0)
Directions = [North, East, South, West]

HitWall = 0
Moved   = 1
Found   = 2

Wall       = '█'.red
Explored   = '.'
Unexplored = '.'.yellow.bold
Oxygen     = '●'.green.bold
Oxygenized = '⦿'.green.bold
Self       = '█'.blue.bold
Home       = 'X'.green.bold

Position = Struct.new(:x, :y) do
  def move(direction); Position.new(x + direction.x, y + direction.y); end
  def to_s; "<x:#{x}, y:#{y}>"; end
end

class Mapper < Boilerstate
  attr_accessor :grid, :bounds_x, :bounds_y, :position, :on_move, :direction, :exploring, :move_counter, :step_counter, :oxygen, :oxygen_count

  def direction_value; @direction.value; end

  def parse(input)
    @bounds_x     = [0, 0]
    @bounds_y     = [0, 0]
    @position     = Position.new(0, 0)
    @grid         = {@position => Unexplored}
    @move_counter = {@position => 0} # number of times we've moved to this tile
    @step_counter = {@position => 0} # least number of steps needed to hit this tile
    @exploring    = @position
    @default      = North
    @on_move      = @options[:on_move]
    @direction    = North
    @oxygen_count = 0
    @program      = Intcode.new(input, reader: method(:direction_value), writer: method(:respond))
  end

  def run(&blk)
    @on_move = blk
    @program.run
  end

  def respond(action)
    case action
    when HitWall
      @grid[@position.move(@direction)] = Wall
    when Moved
      update_position(@position.move(@direction))
    when Found
      update_position(@position.move(@direction))
      @oxygen = @position
      @grid[@position] = Oxygen
    end

    update_explore_state
    update_bounds

    # once we explore everything, then oxygenize everything
    if completely_explored?
      while(needs_more_oxygen?)
        @grid.dup.each do |key, value|
          if value == Oxygen || value == Oxygenized
            Directions.each do |d|
              target = key.move(d)
              @grid[target] = Oxygenized if @grid[target] == Explored
            end
          end
        end

        on_move.call unless on_move.nil?
        @oxygen_count += 1
      end
      
      @program.halted = true
    end
  end


  def needs_more_oxygen?
    @grid.values.any? {|g| g == Explored }
  end

  def completely_explored?
    !@grid.values.any? {|g| g == Unexplored }
  end

  def update_position(value)
    @position = value
    @move_counter[@position] ||= 0
    @move_counter[@position] += 1

    # determine least number of steps needed to get here
    @step_counter[@position] = Directions.reduce(@step_counter[@position]) do |current, direction|
      direction_steps = @step_counter[@position.move(direction)] 
      if current.nil? && direction_steps.nil?
        nil
      elsif current.nil?
        direction_steps + 1
      elsif direction_steps.nil?
        current
      elsif (direction_steps + 1) <= current
        direction_steps + 1
      else
        current
      end
    end
  end

  def update_explore_state
    explored = explored?(position)

    if @grid[@position] != Oxygen
      @grid[@position] = explored ? Explored : Unexplored
    end

    # once we move, unless this is our exploring tile then return to where we
    # came from, if it is our exploring tile, see if we need to update the
    # location we're currently exploring
    if @exploring == @position
      if explored # we're done exploring this tile, move on
        @direction = (next_direction(@position, Unexplored) || least_explored_direction)
        @exploring = @position.move(@direction)

        unless explored?(@exploring)
          on_move.call unless on_move.nil?
        end
      else
        @direction = next_direction(@position, nil) || least_explored_direction 
      end
    else
      @direction = @direction.reverse
    end
  end

  def next_direction(position, with_value)
    return North if @grid[position.move(North)] == with_value
    return East if @grid[position.move(East)] == with_value
    return South if @grid[position.move(South)] == with_value
    return West if @grid[position.move(West)] == with_value
    nil
  end

  def least_explored_direction
    Directions.reduce(North) do |current_least, possible_direction|
      current_least_position = @position.move(current_least)
      direction_position = @position.move(possible_direction)

      if @grid[current_least_position] == Wall # if our current least hits a wall then use the possible
        possible_direction
      elsif @grid[direction_position] == Wall # if our current possible hits a wall then use the least
        current_least
      elsif count_at(current_least_position) < count_at(direction_position)
        current_least 
      else
        possible_direction 
      end
    end
  end

  def count_at(position)
    @move_counter[position] || 0
  end

  def explored?(position)
    return false if @grid[position.move(North)].nil?
    return false if @grid[position.move(South)].nil?
    return false if @grid[position.move(East)].nil?
    return false if @grid[position.move(West)].nil?
    true
  end

  def update_bounds
    @bounds_x[0] = @position.x if @position.x < @bounds_x[0]
    @bounds_x[1] = @position.x if @position.x > @bounds_x[1]
    @bounds_y[0] = @position.y if @position.y < @bounds_y[0]
    @bounds_y[1] = @position.y if @position.y > @bounds_y[1]
  end

  def stringify
    str = "Position: #{@position} / Count: #{@move_counter[@position]} / Steps: #{@step_counter[@position]} / Oxygen Count: #{@oxygen_count}\n\n "
    (@bounds_y[0]-1..@bounds_y[1]+1).each do |y|
      (@bounds_x[0]-1..@bounds_x[1]+1).each do |x|
        if @position.x == x && @position.y == y
          str = str + Self
        elsif x == 0 && y == 0
          str = str + Home
        elsif (contents = @grid[Position.new(x, y)])
          str = str + contents
        else
          str = str + ' '
        end
      end
      str = str + "\n"
    end
    str
  end
end

part "1 & 2" do
  print_output = true
  mapper = Mapper.new(input)
  mapper.run do 
    if print_output
      contents = mapper.stringify # get contents before clearing
      puts `clear`
      puts contents
    end
  end

  # one last print to show the finished product
  puts `clear`
  puts mapper.stringify
  puts "\n" if print_output

  assert_equal(336, mapper.step_counter[mapper.oxygen], "oxygen_position_steps")
  assert_equal(360, mapper.oxygen_count, "oxygen_count")
end
