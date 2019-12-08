# frozen_string_literal: true
# https://adventofcode.com/2019/day/8

require 'pry'
require './boilerplate'

def layers(input, dimensions = {width: 25, height: 6})
  input.strip.chars.each_slice(dimensions[:width] * dimensions[:height]).to_a
end

def combine(layers)
  layers.first.length.times.map do |index|
    layers.find {|l| l[index] == '0' || l[index] == '1' || layers.last == l}[index]
  end
end

def stringify(layer, dimensions = {width: 25, height: 6})
  (dimensions[:width] * dimensions[:height]).times.map do |index|
    (layer[index] == '1' ? '■' : ' ') + ((index + 1) % dimensions[:width] == 0 ? "\n" : '')
  end.join('')
end

part 1 do
  fewest_zeros = layers(input).sort_by {|l| l.count('0')}.first
  puts "  #{'-'.yellow} #{fewest_zeros.count('1') * fewest_zeros.count('2')}" # 2210
end

part 2 do
  assert_call(['0','1','1','0'], :combine, layers('0222112222120000', {width: 2, height: 2}))
  puts "  Solution:\n#{stringify(combine(layers(input)))}" # CGEGE
end
