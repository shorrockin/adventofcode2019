# frozen_string_literal: true

# similar in theory to the array permutation method but allows for lazy creation
# plus the ability so skip large swaths of combitanions.
class Permutations
  attr_accessor :array
  attr_accessor :starting
  attr_accessor :next_indexes
  attr_accessor :next_increment_at

  def initialize(array)
    raise "array must contain unique values" if array.uniq.length != array.length
    @array = array
    reset
  end

  def reset
    @starting = array.length.times.map {|t| t }
    @next_indexes = @starting.dup
    @next_increment_at = nil
  end

  def next
    return nil if @next_indexes.nil? # we're all done iterating
    increment(@next_increment_at) unless @next_increment_at.nil?
    return nil if @next_indexes.nil?

    @next_increment_at = (@array.length - 1)
    @next_indexes.map {|index| @array[index] }
  end

  def increment(element)
    @next_indexes[element] += 1

    if @next_indexes[element] >= array.length
      if element == 0
        @next_indexes[element] = 0
      else
        return increment(element - 1)
      end
    end

    # if we're incrementing anything other than the last digit then we also need
    # to 'reset' the digits that follow to their min values
    if element != @array.length - 1
      index = 0
      (element+1...@array.length).each do |to_update|
        existing_index = @next_indexes.index(index) # loop until we find the next unused value
        while(!existing_index.nil? && existing_index < to_update)
          index += 1
          existing_index = @next_indexes.index(index)
        end

        @next_indexes[to_update] = index
      end
    end

    if @next_indexes == @starting
      @next_indexes = nil # we're back at the start wrap this up
    elsif @next_indexes.uniq.length != @array.length 
      increment(element) # skip it, go to the next one
    end
  end

  def to_a(reset_values = true)
    reset if reset_values
    out = []
    out << n while(n = self.next) 
    out
  end

  def to_s; "Permutations<next_indexes:#{next_indexes}>"; end
end