# frozen_string_literal: true
# https://adventofcode.com/2019/day/13

require 'pry'
require './boilerplate'
require './intcode'

Tile = Struct.new(:x, :y, :id)

class Game < Boilerstate
  attr_accessor :program, :score, :positions, :ball, :paddle

  def parse(input)
    @program = Intcode.new(input, reader: @options[:reader]) 
    @positions = {}
  end

  def run(&blk)
    output = []
    program.writer = Proc.new do |value|
      output << value
      if output.length == 3
        x, y, id = output

        if x == -1 && y == 0
          @score = id
        else
          tile = Tile.new(x, y, id)
          @positions[[x, y]] = tile
          @ball = tile if id == 4
          @paddle = tile if id == 3
          yield if id == 4 && block_given?
        end

        output = []
      end
    end

    program.run
  end

  def stringify
    str = "SCORE: #{score}\n"
    sort_x = @positions.values.sort_by(&:x)
    sort_y = @positions.values.sort_by(&:y)
    min_x, max_x = [sort_x.first.x, sort_x.last.x]
    min_y, max_y = [sort_y.first.y, sort_y.last.y]

    (min_y..max_y).each do |y|
      (min_x..max_x).each do |x|
        if (tile = @positions[[x, y]])
          str = str + (case tile.id
          when 0 then ' '
          when 1 then '█'.red
          when 2 then '█'.blue
          when 3 then '='.bold
          when 4 then '●'.teal
          else; ' '; end)
        end
      end
      str = str + "\n"
    end
    str
  end
end


part 1 do
  game = Game.new(input)
  game.run
  assert_equal(348, game.positions.values.select {|t| t.id == 2 }.length, "game.blocks.length")
end

part 2 do
  direction = 0

  game = Game.new(input, reader: -> {direction})
  game.program.write(0, 2)

  game.run do
    puts `clear`
    puts game.stringify

    if !game.paddle.nil? && !game.ball.nil?
      direction = game.ball.x <=> game.paddle.x
    end
  end

  # draw it one more time now that the game has finished
  puts `clear`
  puts game.stringify
end
