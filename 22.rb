# frozen_string_literal: true
# https://adventofcode.com/2019/day/22

require 'pry'
require './boilerplate'

NewStack = Proc.new {|deck, index| deck.size - index - 1}
def Cut(amount); Proc.new {|deck, index| (index + deck.size - amount) % deck.size}; end
def Increment(amount); Proc.new {|deck, index| (index * amount) % deck.size}; end

Polynomial = Struct.new(:starting_a, :starting_b, :num_cards) do
  def solve(a, b, m, n)
    if m == 0
      return 1, 0
    elsif m % 2 == 0
      return solve(a*a%n, (a*b+b)%n, (m/2.0).floor, n)
    else
      c, d = solve(a,b,m-1,n)
      return a*c%n, (a*d+b)%n      
    end
  end

  def shuffle(position, num_shuffles)
    a, b = solve(starting_a, starting_b, num_shuffles, num_cards)
    ((position * a) + b) % num_cards
  end
end

class Deck
  attr_accessor :size

  def initialize(size, shuffles = [])
    @size     = size
    @shuffles = shuffles
  end

  def index_of_card(card)
    @shuffles.reduce(card) {|current, shuffle| shuffle.call(self, current)}
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
    else
      raise "invalid card parsing"
    end
  end
end

def parse_to_polynomial(num_cards, input)
  a, b = [1, 0]
  input.reverse.map do |line|
    if line.start_with?('cut') 
      n = line.gsub('cut', '').to_i
      b = (b+n) % num_cards
    elsif line.start_with?('deal into new stack')
      a = -a
      b = num_cards - b - 1
    elsif line.start_with?('deal with increment')
      n = line.gsub('deal with increment', '').to_i
      z = n.pow(num_cards - 2, num_cards)
      a = a*z % num_cards
      b = b*z % num_cards
    else
      raise "invalid card parsing"
    end
  end

  Polynomial.new(a, b, num_cards)
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
  # I did not do this on my own. I did a lot of reading of others solutions as
  # the math was outside of me, and researched a bunch of different ways to
  # recompose the linear congruent generator to produce the results needed.
  num_cards = 119315717514047
  num_shuffles = 101741582076661
  assert_call_on(parse_to_polynomial(num_cards, input), 79855812422607, :shuffle, 2020, num_shuffles)
end
