# frozen_string_literal: true
# https://adventofcode.com/2019/day/1

require 'pry'
require './boilerplate'

def fuel_for_mass(mass, recurse = false)
  fuel = (mass / 3).floor - 2
  return 0 if fuel < 0
  return (fuel + fuel_for_mass(fuel, true)) if recurse
  fuel
end

def fuel_for_modules(modules, recurse = false)
  modules.reduce(0) {|sum, m| sum + fuel_for_mass(m, recurse)}
end

part 1 do
  assert_call(2, :fuel_for_mass, 12)
  assert_call(2, :fuel_for_mass, 14)
  assert_call(654, :fuel_for_mass, 1969)
  assert_call(33583, :fuel_for_mass, 100756)
  assert_call(656, :fuel_for_modules, [12, 1969])
  log_call(:fuel_for_modules, input.map(&:to_i)) # 3465154
end

part 2 do
  assert_call(2, :fuel_for_mass, 14, true)
  assert_call(966, :fuel_for_mass, 1969, true)
  assert_call(50346, :fuel_for_mass, 100756, true)
  log_call(:fuel_for_modules, input.map(&:to_i), true) # 5194864
end
