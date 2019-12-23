# frozen_string_literal: true
# https://adventofcode.com/2019/day/22

require 'pry'
require './boilerplate'

NewStack = Proc.new {|deck, index| deck.size - index - 1}
def Cut(size); Proc.new {|deck, index| (index + deck.size - size) % deck.size}; end
def Increment(amount); Proc.new {|deck, index| (index * amount) % deck.size}; end

class Deck
  attr_accessor :size

  def initialize(size, shuffles = [])
    @size     = size
    @shuffles = shuffles
  end

  def index_of_card(card)
    @shuffles.reduce(card) {|current, shuffle| out = shuffle.call(self, current)}
  end
end

def parse(input)
  input.map do |line|
    if line.start_with?('cut') 
      Cut(line.gsub('cut', '').to_i)
    elsif line.start_with?('deal into new stack')
      NewStack
    elsif line.start_with?('deal with increment')
      Increment(line.gsub('deal with increment', '').to_i)
    end
  end
end

part 1 do
  assert_call_on(Deck.new(10, [NewStack]), 1, :index_of_card, 8)
  assert_call_on(Deck.new(10, [Cut(3)]), 6, :index_of_card, 9)
  assert_call_on(Deck.new(10, [Cut(-4)]), 2, :index_of_card, 8)
  assert_call_on(Deck.new(10, [Increment(3)]), 8, :index_of_card, 6)
  assert_call_on(Deck.new(10, [Increment(3)]), 2, :index_of_card, 4)
  assert_call_on(Deck.new(10, [Cut(6), Increment(7), NewStack]), 6, :index_of_card, 5)
  assert_call_on(Deck.new(10007, parse(input)), 6526, :index_of_card, 2019)
end

part 2 do
end
