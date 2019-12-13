# frozen_string_literal: true
# https://adventofcode.com/2019/day/13

require 'pry'
require './boilerplate'
require './intcode'

Tile = Struct.new(:x, :y, :id)

class Game < Boilerstate
  attr_accessor :program, :score, :positions, :ball, :paddle
  def parse(input)
    @program = Intcode.new(input, retain_input: true, block_on_output: true)
    @positions = {}
  end

  def run(input = nil)
    while(true)
      x, y, id = [program.run(input), program.run(input), program.run(input)]
      
      if x == -1 && y == 0
        @score = id
      else
        tile = Tile.new(x, y, id)
        @positions[[x, y]] = Tile.new(x, y, id)
        @ball = tile if id == 4
        @paddle = tile if id == 3
      end

      break if id == 4 # return once we update the ball
    end
  end

  def stringify
    sort_x = @positions.values.sort_by(&:x)
    sort_y = @positions.values.sort_by(&:y)
    min_x = sort_x.first.x
    max_x = sort_x.last.x
    min_y = sort_y.first.y
    max_y = sort_y.last.y
    str   = "Score: #{score}\n"

    (min_y..max_y).each do |y|
      (min_x..max_x).each do |x|
        if (tile = @positions[[x, y]])
          str = str + (case tile.id
          when 0 then ' '
          when 1 then 'x'
          when 2 then '■'
          when 3 then '='
          when 4 then 'o'
          else; ' '; end)
        end
      end
      str = str + "\n"
    end
    str
  end
end


part 1 do
  # game = Game.new(input)
  # game.run
  # puts "Blocks: #{game.tiles.select {|t| t.id == 2 }.length}" # 348
end

part 2 do
  running = true
  game = Game.new(input)
  game.program.program[0] = 2
  game.run(0)

  while(running)
    puts `clear`
    puts game.stringify

    ball = game.positions.values.find {|t| t.id == 4}
    tile = game.positions.values.find {|t| t.id == 3}

    if tile.nil?
      game.run(0)
    elsif ball.x > tile.x
      game.run(1)
    elsif ball.x == tile.x
      game.run(0)
    else
      game.run(-1)
    end
  end
end
