# frozen_string_literal: true
# https://adventofcode.com/2019/day/25

require 'pry'
require './boilerplate'
require './intcode'

NEWLINE = 10.chr

# Items
# - Electromagnet (stuck
# - Food Ration (can take)
# - Manifold (can take)
part 1 do
  instructions = [
    # Hull Breach N/E
    "east", 
    # Hot Chocolate Fountain E/S/W
    "take food ration", 
    "east", 
    # Gift Wrapping Center E/S/W
    "take manifold", 
    "east",
    # Navigation N/E/W
    "east",
    # Kitchen W
    "take jam",
    "west",
    # Navigation N/E/W
    "north",
    # Holodeck N/E/S
    "east",
    # Warp Drive Maintenance W
    "take spool of cat6",
    "west",
    # Holodeck N/E/S
    "north",
    # Passages S
    "take fuel cell",
    "south",
    # Holodeck N/E/S
    "south",
    # Navigation N/E/W
    "west",
    # Gift Wrapping Center E/S/W
    "south",
    # Sick Bay N
    "north",
    # Gift Wrapping Center E/S/W
    "west",
    # Hot Chocolate Fountain E/S/W
    "south",
    # Science Lab N
    "take prime number",
    "north",
    # Hot Chocolate Fountain E/S/W
    "west",
    # Hull Breach
    "north",
    # Hallway (Photons) N/S/W
    "west",
    # Engineering (Escape Pad) N/E
    "north",
    # Stables (Giant Eletromagnet) S/W
    "west",
    # Security Checkpoint (Pressure Door) N/E
    "east", 
    "south", 
    "east",
    # Hallway (Photons) N/S/W
    "north",
    # Arcade N/S/W
    "west",
    # Observator (E)
    "take mug",
    "east",
    # Arcade N/S/w
    "north",
    # Crew Quarters E/S
    "east",
    # Cooridor E/W
    "east",
    # Storage W
    "take loom",
    "west",
    "west",
    "south",
    "south",
    # Hallway
    "west",
    "north",
    "west",
    # Security Checkpoint N/E
    "inv"
  ].join(10.chr).chars.map(&:ord)
  instructions << 10

  items = [
    "jam",
    "loom",
    "mug",
    "spool of cat6",
    "prime number",
    "food ration",
    "fuel cell",
    "manifold",
  ].permutation

  intcode          = Intcode::Runner.new(input)
  last_char        = nil
  reading_location = false
  location         = nil
  testing          = false

  intcode.writer = Proc.new do |output|
    if reading_location && output.chr != '='
      location = location + output.chr
    end

    if last_char == '=' && output.chr == '=' 
      if reading_location = !reading_location
        location = ""
      else
        location = location.strip
        if testing && location != 'Security Checkpoint' && location != "Pressure-Sensitive Floor"
          binding.pry
          testing = false
        end
      end
    end

    last_char = output.chr
    putc last_char unless testing
  end

  intcode.reader = Proc.new do 
    if testing && instructions.length == 0
      perm = items.next
      puts "testing #{perm}"
      drops = perm.map {|i| ["drop #{i}", NEWLINE, "north", NEWLINE] }.flatten + perm.map {|i| ["take #{i}", NEWLINE, "north", NEWLINE]}.flatten
      instructions = drops.join().chars.map(&:ord)
    end

    c = if instructions.length > 0
      instructions.shift 
    else
      read_stdin_char
    end

    if c == "?"
      testing = true
    end

    binding.pry if c == '^'
    putc c unless testing
    c.ord == 13 ? 10 : c.ord
  end
  intcode.run
end

part 2 do
end
