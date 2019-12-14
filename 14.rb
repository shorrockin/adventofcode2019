# frozen_string_literal: true
# https://adventofcode.com/2019/day/14

require 'pry'
require './boilerplate'

ORE = 'ORE'

Ingredient = Struct.new(:amount, :chemical) do
  def to_s; "Ingredient<#{amount} #{chemical}>"; end
end

class Reaction < Boilerstate
  attr :source, :inputs, :output
  def parse(line)
    @source = line
    @inputs, @output = line.split('=>').map(&:strip)
    @inputs = @inputs.split(',').map(&:strip) 
    @inputs = @inputs.map do |i|
      amount, chemical = i.split(' ').map(&:strip)
      Ingredient.new(amount.to_i, chemical)
    end

    amount, chemical = @output.split(' ')
    @output = Ingredient.new(amount.to_i, chemical)
  end

  def to_s; "Reaction<#{@source}>"; end
end

class Solver < Boilerstate
  attr_accessor :reactions

  def parse(lines)
    @reactions = lines.map do |l| 
      reaction = Reaction.new(l)
      [reaction.output.chemical, reaction]
    end.to_h
  end

  def ore_required_for(amount, chemical, inventory = {})
    reaction = @reactions[chemical]

    # use as much as we can from the existing inventory, either use part of
    # it or all of it
    if !inventory[chemical].nil? 
      if amount > inventory[chemical]
        amount -= inventory[chemical]
        inventory[chemical] = 0
      else
        inventory[chemical] -= amount
        return {amount: 0, extra: 0}
      end
    end   

    # figure out how many times we need to run this reaction in order to get the
    # desired amount
    times = (amount / reaction.output.amount.to_f).ceil
    chem_produced = (reaction.output.amount * times)

    # logic for ore, in which we have unlimited amount and is our return
    # condition, only used when the only input for a reaction is ore
    if reaction.inputs.length == 1 && reaction.inputs[0].chemical == ORE
      ore_needed    = (reaction.inputs[0].amount * times)
      return {amount: ore_needed, extra: (chem_produced - amount)}
    else
      ore_needed = 0
      reaction.inputs.each do |input|
        required    = ore_required_for(input.amount * times, input.chemical, inventory)
        ore_needed += required[:amount]
        if required[:extra] > 0
          inventory[input.chemical] ||= 0
          inventory[input.chemical] += required[:extra]
        end
      end

      {amount: ore_needed, extra: (chem_produced - amount)}
    end
  end

  def fuel_for_ore(ore_amount)
    ore_for_one_fuel = ore_required_for(1, 'FUEL')[:amount]
    current_guess = ore_amount / ore_for_one_fuel
    current_ore   = ore_required_for(current_guess, 'FUEL')[:amount]

    while (current_ore != ore_amount)
      previous_guess = current_guess
      current_guess  = (current_guess * (((ore_amount - current_ore) / ore_amount.to_f) + 1.0)).round
      current_ore    = ore_required_for(current_guess, 'FUEL')[:amount]

      # if the guess didn't change we're on the boundary
      if previous_guess == current_guess
        if current_ore > ore_amount
          return current_guess - 1
        elsif ore_required_for(current_guess + 1, 'FUEL')[:amount] > ore_amount
          return current_guess
        else
          return current_guess + 1
        end
      end
    end

    current_guess
  end
end

EXAMPLE_ONE = ['10 ORE => 10 A', '1 ORE => 1 B', '1 ORE => 2 FOO', '7 A, 1 B => 1 C', '7 A, 1 C => 1 D', '7 A, 1 D => 1 E', '7 A, 1 E => 1 FUEL']
EXAMPLE_TWO = ['9 ORE => 2 A', '8 ORE => 3 B', '7 ORE => 5 C', '3 A, 4 B => 1 AB', '5 B, 7 C => 1 BC', '4 C, 1 A => 1 CA', '2 AB, 3 BC, 4 CA => 1 FUEL']
EXAMPLE_THREE = [
  '157 ORE => 5 NZVS', 
  '165 ORE => 6 DCFZ', 
  '44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL', 
  '12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ', 
  '179 ORE => 7 PSHF',
  '177 ORE => 5 HKGWZ',
  '7 DCFZ, 7 PSHF => 2 XJWVT',
  '165 ORE => 2 GPVTF',
  '3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT'
]
EXAMPLE_FOUR = [
  '2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG',
  '17 NVRVD, 3 JNWZP => 8 VPVL',
  '53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL',
  '22 VJHF, 37 MNCFX => 5 FWMGM',
  '139 ORE => 4 NVRVD',
  '144 ORE => 7 JNWZP',
  '5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC',
  '5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV',
  '145 ORE => 6 MNCFX',
  '1 NVRVD => 8 CXFTF',
  '1 VJHF, 6 MNCFX => 4 RFSQX',
  '176 ORE => 6 VJHF',
]

part 1 do
  reaction = Reaction.new('7 A, 1 D => 1 E')
  assert_call_on(reaction, [Ingredient.new(7, 'A'), Ingredient.new(1, 'D')], :inputs)
  assert_call_on(reaction, Ingredient.new(1, 'E'), :output)

  solver = Solver.new(EXAMPLE_ONE)
  assert_call_on(solver, {amount: 10, extra: 0}, :ore_required_for, 10, 'A')
  assert_call_on(solver, {amount: 10, extra: 5}, :ore_required_for, 5, 'A')
  assert_call_on(solver, {amount: 10, extra: 9}, :ore_required_for, 1, 'A')
  assert_call_on(solver, {amount: 1, extra: 0}, :ore_required_for, 1, 'B')
  assert_call_on(solver, {amount: 1, extra: 1}, :ore_required_for, 1, 'FOO')
  assert_call_on(solver, {amount: 1, extra: 0}, :ore_required_for, 2, 'FOO')
  assert_call_on(solver, {amount: 2, extra: 1}, :ore_required_for, 3, 'FOO')
  assert_call_on(solver, {amount: 0, extra: 0}, :ore_required_for, 1, 'E', {'E' => 1})
  assert_call_on(solver, {amount: 11, extra: 0}, :ore_required_for, 2, 'C', {'C' => 1})
  assert_call_on(solver, {amount: 10, extra: 5}, :ore_required_for, 15, 'A', {'A' => 10})
  assert_call_on(solver, {amount: 31, extra: 0}, :ore_required_for, 1, 'FUEL')
  assert_call_on(solver, {amount: 62, extra: 0}, :ore_required_for, 2, 'FUEL')

  solver = Solver.new(EXAMPLE_TWO)
  assert_call_on(solver, {amount: 165, extra: 0}, :ore_required_for, 1, 'FUEL')

  solver = Solver.new(EXAMPLE_THREE)
  assert_call_on(solver, {amount: 13312, extra: 0}, :ore_required_for, 1, 'FUEL')

  solver = Solver.new(EXAMPLE_FOUR)
  assert_call_on(solver, {amount: 180697, extra: 0}, :ore_required_for, 1, 'FUEL')
  assert_call_on(Solver.new(input), {amount: 1065255, extra: 0}, :ore_required_for, 1, 'FUEL') 
end

part 2 do
  assert_call_on(Solver.new(EXAMPLE_THREE), 82892753, :fuel_for_ore, 1000000000000)
  assert_call_on(Solver.new(EXAMPLE_FOUR), 5586022, :fuel_for_ore, 1000000000000)
  assert_call_on(Solver.new(input), 1766154, :fuel_for_ore, 1000000000000) # !1766155
end
