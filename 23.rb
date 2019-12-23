# frozen_string_literal: true
# https://adventofcode.com/2019/day/23

require 'pry'
require './boilerplate'
require './intcode'

Instruction = Struct.new(:destination, :x, :y, :nat)

class Computer
  attr_accessor :id, :intcode, :booted

  def initialize(id, code, network)
    @id = id
    @intcode = Intcode::Runner.new(code, run_once: true)
    @booted = false
    network.add(self)
  end

  def boot
    @booted = true
    @id
  end

  def halted; @intcode.halted; end
  def run; @intcode.run; end
end

NAT_ADDRESS = 255

class Network
  attr_accessor :nat_packet

  def initialize(input, computers: 50, halt_on_nat: false)
    @num_computers = computers
    @output_queue = {}
    @messages = {}
    @computers = []
    @halted = false
    @halt_on_nat = halt_on_nat
    @nat_packet = nil
    @idle = {}
    @last_sent_nat = false
    @lv = nil

    (0...computers).map {|id| Computer.new(id, input, self)}
  end

  def add(computer)
    computer.intcode.writer = Proc.new {|output| process_output(computer, output)}
    computer.intcode.reader = Proc.new {process_input(computer)}
    @computers << computer
  end

  def process_output(computer, output)
    message = @messages[computer.id]

    if message.nil?
      @messages[computer.id] = Instruction.new(output, nil, nil, false)
    elsif message.x.nil?
      message.x = output
    else
      message.y = output
      @messages.delete(computer.id)

      if message.destination == NAT_ADDRESS 
        @halted = true if @halt_on_nat
        @nat_packet = message
        @nat_packet.nat = true
      else
        @output_queue[message.destination] ||= []
        @output_queue[message.destination] << message
      end
    end
  end

  def all_computers_idle?; @idle.select {|k, v| v == true }.length == @num_computers; end

  def process_input(computer)
    return computer.boot unless computer.booted

    queue = @output_queue[computer.id]

    if !queue.nil? && queue.any?
      @idle[computer.id] = false
      message = queue.first

      if !message.x.nil?
        out = message.x
        message.x = nil
        out
      else
        if computer.id == 0
          if @last_sent_nat && message.nat && @lv == message.y
            @halted = true
          end
          @lv = message.y
          @last_sent_nat = message.nat
        end

        @output_queue[computer.id].shift
        message.y
      end
    elsif all_computers_idle? && !@nat_packet.nil?
      raise "nat packet nil while all computers idle" if @nat_packet.nil?
      @idle[0] = false
      @output_queue[0] ||= []
      @output_queue[0] << Instruction.new(0, @nat_packet.x, @nat_packet.y, true)
      -1
    else
      @idle[computer.id] = true
      -1
    end
  end

  def run
    @computers.each(&:run) while(!@halted && !@computers.select(&:halted).any?)
  end
end

part 1 do
  network = Network.new(input, halt_on_nat: true)
  network.run
  assert_call_on(network.nat_packet, 18604, :y)
end

part 2 do
  network = Network.new(input, halt_on_nat: false)
  network.run
  assert_call_on(network.nat_packet, 11880, :y)
end
