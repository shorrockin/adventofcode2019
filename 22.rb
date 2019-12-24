# frozen_string_literal: true
# https://adventofcode.com/2019/day/22

require 'pry'
require './boilerplate'

NewStack = Proc.new {|deck, index| deck.size - index - 1}
def Cut(amount); Proc.new {|deck, index| (index + deck.size - amount) % deck.size}; end
def Increment(amount); Proc.new {|deck, index| (index * amount) % deck.size}; end

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
    end
  end
end

part 1 do
  # assert_call_on(Deck.new(10, [NewStack]), 1, :index_of_card, 8)
  # assert_call_on(Deck.new(10, [Cut(3)]), 6, :index_of_card, 9)
  # assert_call_on(Deck.new(10, [Cut(-4)]), 2, :index_of_card, 8)
  # assert_call_on(Deck.new(10, [Increment(3)]), 8, :index_of_card, 6)
  # assert_call_on(Deck.new(10, [Increment(3)]), 2, :index_of_card, 4)
  # assert_call_on(Deck.new(10, [Cut(6), Increment(7), NewStack]), 6, :index_of_card, 5)
  # assert_call_on(Deck.new(10007, parse(input)), 6526, :index_of_card, 2019)
end

part 2 do
  num_cards    = 119315717514047
  num_shuffles = 101741582076661
  previous = []
  deck = Deck.new(num_cards, parse(input))
  last_index = 2020

  10.times do |time|
    original = last_index
    last_index = deck.index_of_card(last_index)
    binding.pry if previous.include?(last_index)
    previous << last_index

    puts "From #{original} -> #{last_index}, D: #{last_index - original} / M: #{(last_index + original) % num_cards} / T: #{time}"
  end

  assert_call_on(Deck.new(num_cards, parse(input)), 0, :index_of_card, 2020)
end
