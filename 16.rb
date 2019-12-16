# frozen_string_literal: true
# https://adventofcode.com/2019/day/16

require 'pry'
require './boilerplate'
require './memoize'

Pattern = Struct.new(:index, :multiplier);
DEFAULT_PATTERN = [0, 1, 0, -1]

# in a class so we can use memoize helper, could work around it, but /shrug
class FFT < Boilerstate
  include RubyMemoized

  def parse(input); end

  def process(signal, phases = 100, message_offset = 0)
    signal = signal.to_s.chars.map(&:to_i)

    phases.times do |phase|
      last_signal = signal.dup
      last_value = 0

      if message_offset > (signal.length / 2)
        (signal.length - message_offset).times do |count|
          reverse_index = signal.length - count - 1
          signal[reverse_index] = last_value + signal[reverse_index]
          last_value = signal[reverse_index]
        end
      else
        # when using an offset the numbers preceeding that offset have no impact
        # on the numbers which follows (since they will be multiplied by 0)
        (message_offset...signal.length).each do |signal_digit_index|
          signal[signal_digit_index] = pattern_repeated(signal_digit_index, signal.length).reduce(0) do |sum, pattern|
            sum + (last_signal[pattern.index] * pattern.multiplier)
          end.abs.digits.first
        end
      end
    end

    if message_offset > 0
      # binding.pry
      signal[message_offset...message_offset+8].map {|d| d.abs.digits.first}.join('')
    else
      signal.join('') 
    end
  end

  def message_offset(signal)
    raise unless signal.length >= 8
    signal[0...7]
  end

  memoized

  def pattern_repeated(digit_index, signal_length)
    out = []
    pattern = []

    DEFAULT_PATTERN.each do |num|
      pattern << num
      digit_index.times {pattern << num}
    end

    signal_length.times do |index|
      multiplier = pattern[(index + 1) % pattern.length]
      next if multiplier == 0
      out << Pattern.new(index, multiplier)
    end

    out
  end
end

def fft(signal, phases = 100, message_offset = 0)
  FFT.new(nil).process(signal, phases, message_offset)
end

def repeat_string(str, amount)
  amount.times.map {str}.join('')
end

def message_offset(signal)
  raise unless signal.length >= 8
  signal[0...7].to_i
end

part 1 do
  assert_call("48226158", :fft, 12345678, 1)
  assert_call("01029498", :fft, 12345678, 4)
  assert_call("37153056445003200562627103769225155139842510190979335268338370645264863888172759110420883203162254985128361608189657808588525582615354788317743811104192651352192857797860559682693643587887532405899417344376754084957794179537178594598257859436896842933146683662828221883611855919370590474545054891314803931197155140523089279115076902834738449248541872115707751091286033496447012964312388060044415791228916730295717302897497479861800427249459138169329681004995571252786406234419624286275861942983943359177442235894965025852806014091317752939067438204444210736389756204326833266433366105471992789810100353295108821060949345328625162363812404354702861550", :fft, input)
end

part 2 do
  assert_call('ABCABCABC', :repeat_string, 'ABC', 3)
  assert_call(303673, :message_offset, '03036732577212944063491565474664')
  assert_call('84462026', :fft, repeat_string('03036732577212944063491565474664', 10000), 100, message_offset('03036732577212944063491565474664'))
  assert_call('78725270', :fft, repeat_string('02935109699940807407585447034323', 10000), 100, message_offset('02935109699940807407585447034323'))
  assert_call('53553731', :fft, repeat_string('03081770884921959731165446850517', 10000), 100, message_offset('03081770884921959731165446850517'))
  assert_call('60592199', :fft, repeat_string(input, 10000), 100, message_offset(input))
end
