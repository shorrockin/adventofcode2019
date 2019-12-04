# frozen_string_literal: true
# https://adventofcode.com/2019/day/4

require 'pry'
require './boilerplate'

# NOTE: This is a litle bit over-engineered, while working on part 1 i was
# convinced that part 2 would blow the numbers to a size where incrementing them
# was unsustainable, so i added the custom incrementor to increment by the rules
# set forth. previous years have burnt me i guess.

class Guess
  attr_accessor :values

  def initialize(initial)
    @values = initial.to_s.each_char.map(&:to_i)
  end

  def increment(index = (values.length - 1))
    if values[index] == 9
      increment(index - 1)
    else
      values[index] += 1
      while(index != (values.length - 1))
        values[index + 1] = values[index]
        index += 1
      end
    end
    @values
  end

  def duplicates
    last = nil
    values.each do |value|
      return true if value == last
      last = value
    end
    false
  end

  def exact_duplicates
    last = nil
    count = 0

    values.each_with_index do |value|
      if last == value
        count += 1
      else
        return true if count == 1
        count = 0
      end
      last = value
    end

    count == 1
  end

  def less_than(other_guess)
    other_values = other_guess.values

    # sanity checks, should not really ever happen in this problem
    return true  if other_values.length > values.length
    return false if values.length > other_values.length

    index = 0
    while index < values.length
      return true  if values[index] < other_values[index]
      return false if values[index] > other_values[index]

      index += 1
    end

    false
  end
end

def combinations(start, finish, count_by = :duplicates)
  finish  = Guess.new(finish)
  current = Guess.new(start)
  count   = 0

  while(current.less_than(finish))
    count += 1 if current.send(count_by)
    current.increment
  end

  count
end

part 1 do
  assert_call_on(Guess.new(1234), [1, 2, 3, 4], :values)
  assert_call_on(Guess.new(1234), [1, 2, 3, 5], :increment)
  assert_call_on(Guess.new(1239), [1, 2, 4, 4], :increment)
  assert_call_on(Guess.new(1999), [2, 2, 2, 2], :increment)
  assert_call_on(Guess.new(1999), true, :duplicates)
  assert_call_on(Guess.new(1919), false, :duplicates)
  assert_call_on(Guess.new(1229), true, :duplicates)
  assert_call_on(Guess.new(1229), true, :less_than, Guess.new(1241))
  assert_call_on(Guess.new(1241), false, :less_than, Guess.new(1229))
  assert_call(2, :combinations, 100, 112)

  # manually adjusted start to first matching value
  # was: 206938
  log_call(:combinations, 222222, 679128) # 1653
end

part 2 do
  assert_call_on(Guess.new(1999), false, :exact_duplicates)
  assert_call_on(Guess.new(1992), true, :exact_duplicates)
  assert_call_on(Guess.new(112233), true, :exact_duplicates)
  assert_call_on(Guess.new(123444), false, :exact_duplicates)
  assert_call_on(Guess.new(111122), true, :exact_duplicates)
  assert_call_on(Guess.new(111123), false, :exact_duplicates)

  log_call(:combinations, 222222, 679128, :exact_duplicates) # 1133
end
