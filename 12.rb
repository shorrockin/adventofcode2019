# frozen_string_literal: true
# https://adventofcode.com/2019/day/12

require 'pry'
require './boilerplate'

Location = Struct.new(:x, :y, :z) do
  def +(location); Location.new(x + location.x, y + location.y, z + location.z); end
  def to_s; "Location(x:#{x} y:#{y} z:#{z})"; end
end

Moon = Struct.new(:location, :velocity) do
  def to_s; "Moon(location=#{location.x},#{location.y},#{location.z} velocity=#{velocity.x},#{velocity.y},#{velocity.z})"; end
  def dup; Moon.new(location.dup, velocity.dup); end
end

class SolarSystem < Boilerstate
  attr_accessor :moons
  def parse(lines)
    @moons = lines.map do |line|
      coords = line.scan(/<x=(.*), y=(.*), z=(.*)>/).flatten.map(&:to_i)
      Moon.new(
        Location.new(coords[0], coords[1], coords[2]),
        Location.new(0, 0, 0)
      )
    end
    @start_positions = @moons.map(&:dup)
  end

  def start_position_x?(idx); @moons[idx].location.x == @start_positions[idx].location.x && @moons[idx].velocity.x == @start_positions[idx].velocity.x; end
  def start_position_y?(idx); @moons[idx].location.y == @start_positions[idx].location.y && @moons[idx].velocity.y == @start_positions[idx].velocity.y; end
  def start_position_z?(idx); @moons[idx].location.z == @start_positions[idx].location.z && @moons[idx].velocity.z == @start_positions[idx].velocity.z; end

  def start_position?
    {
      x: (start_position_x?(0) && start_position_x?(1) && start_position_x?(2) && start_position_x?(3)),
      y: (start_position_y?(0) && start_position_y?(1) && start_position_y?(2) && start_position_y?(3)),
      z: (start_position_z?(0) && start_position_z?(1) && start_position_z?(2) && start_position_z?(3)),
    }
  end

  def energy
    @moons.reduce(0) do |sum, moon|
      potential = moon.location.x.abs + moon.location.y.abs + moon.location.z.abs
      kinetic = moon.velocity.x.abs + moon.velocity.y.abs + moon.velocity.z.abs
      sum + (potential * kinetic)
    end
  end

  def step
    gravities = @moons.map {|moon| [moon, Location.new(0, 0, 0)]}.to_h
    @moons.combination(2).each do |left, right|
      gx = (left.location.x - right.location.x == 0 ? 0 : (left.location.x - right.location.x < 0 ? 1 : -1))
      gy = (left.location.y - right.location.y == 0 ? 0 : (left.location.y - right.location.y < 0 ? 1 : -1))
      gz = (left.location.z - right.location.z == 0 ? 0 : (left.location.z - right.location.z < 0 ? 1 : -1))
      gravities[left] = gravities[left] + Location.new(gx, gy, gz)
      gravities[right] = gravities[right] + Location.new(gx * -1, gy * -1, gz * -1)
    end

    @moons.each do |moon| 
      moon.velocity = moon.velocity + gravities[moon]
      moon.location = moon.location + moon.velocity
    end
  end
end

EXAMPLE_ONE = ['<x=-1, y=0, z=2>', '<x=2, y=-10, z=-7>', '<x=4, y=-8, z=8>', '<x=3, y=5, z=-1>'] 

part 1 do
  solar_system = SolarSystem.new(EXAMPLE_ONE)

  assert_call_on(solar_system.moons, 4, :length)
  assert_call_on(solar_system.moons, Moon.new(Location.new(-1, 0, 2), Location.new(0, 0, 0)), :first)
  assert_call_on(solar_system.moons, Moon.new(Location.new(3, 5, -1), Location.new(0, 0, 0)), :last)

  solar_system.step
  assert_call_on(solar_system.moons, Moon.new(Location.new(2, -1, 1), Location.new(3, -1, -1)), :first)
  assert_call_on(solar_system.moons, Moon.new(Location.new(2, 2, 0), Location.new(-1, -3, 1)), :last)

  9.times {solar_system.step}
  assert_call_on(solar_system.moons, Moon.new(Location.new(2, 1, -3), Location.new(-3, -2, 1)), :first)
  assert_call_on(solar_system.moons, Moon.new(Location.new(2, 0, 4), Location.new(1, -1, -1)), :last)
  assert_call_on(solar_system, 179, :energy)

  solar_system = SolarSystem.new(input)
  1000.times {solar_system.step}
  assert_call_on(solar_system, 12053, :energy)
end

part 2 do
  solar_system = SolarSystem.new(EXAMPLE_ONE)
  assert_call_on(solar_system, {x: true, y: true, z: true}, :start_position?)
  solar_system.step
  assert_call_on(solar_system, {x: false, y: false, z: false}, :start_position?)
  2771.times {solar_system.step}
  assert_call_on(solar_system, {x: true, y: true, z: true}, :start_position?)

  solar_system = SolarSystem.new(input)
  solar_system.step
  count = 1
  repeat_at = Location.new(0, 0, 0)
  
  while(repeat_at.x == 0 || repeat_at.y == 0 || repeat_at.z == 0)
    solar_system.step
    count += 1
    start_position = solar_system.start_position?

    repeat_at.x = count if start_position[:x] && repeat_at.x == 0
    repeat_at.y = count if start_position[:y] && repeat_at.y == 0
    repeat_at.z = count if start_position[:z] && repeat_at.z == 0
  end
  lcm = [repeat_at.x, repeat_at.y, repeat_at.z].reduce(1, :lcm)
  assert_equal(320380285873116, lcm, "LCM of #{repeat_at}")
end
