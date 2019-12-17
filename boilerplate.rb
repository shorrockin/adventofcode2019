# frozen_string_literal: true
# Advent Boilerplate Start
# require 'pry'

class String
  def colorize(color_code); "\e[#{color_code}m#{self}\e[0m"; end
  def red; colorize(31); end
  def green; colorize(32); end
  def yellow; colorize(33); end
  def blue; colorize(34); end
  def pink; colorize(35); end
  def teal; colorize(36); end
  def bold; colorize(1); end
end

module Loggable
  attr_accessor :logging, :log_depth

  def log(s, *args);
    @log_depth ||= "  "
    out = nil

    puts "#{@log_depth}#{s} #{args.map(&:to_s).join(", ")}" unless !@logging;

    if block_given?
      original_depth = @log_depth
      @log_depth = @log_depth + "  "
      begin
        out = yield
      ensure
        @log_depth = original_depth
      end
    end

    return out
  end
end

class Boilerstate
  include Loggable
  attr_accessor :input, :options
  def initialize(input, **options)
    @options = options || {}
    @logging = @options[:logging] || false
    parse(input)
  end

  def parse(input)
    raise NotImplementedError
  end
end

def value_string(val)
  value_str = val
  value_str = '"' + value_str + '"' if val.is_a?(String)
  value_str = 'nil' if val.nil?
  value_str
end

def assert_equal(expect, value, description)
  puts "  #{'✔'.green} #{description} == #{value_string(value)}" if value == expect
  puts "  #{'✖'.red} #{description}: expected #{value_string(expect)}, received #{value_string(value)}" if value != expect
  value
end

def assert_call(expect, *args)
  assert_call_on(self, expect, *args)
end

def log_call(method, *args)
  log_call_on(self, method, *args)
end

def assert_call_on(target, expect, *args)
  log_call_on(target, *args) {|m, r, desc| assert_equal(expect, r, "#{m}(#{desc})")}
end

def log_call_on(target, method, *args)
  arg_description = args.to_s[1...-1]
  arg_description = "..." if arg_description.length > 10
  method, arg_description = method if method.is_a?(Array)

  result = target.send(method, *args)
  return yield method, result, arg_description if block_given?
  puts "  #{'-'.yellow} #{method}(#{arg_description}) == #{value_string(result)}"
end

def input(strip_newlines = true)
  # ARGV can only be used once
  return @input.dup unless @input.nil?

  if ARGV.length == 0
    raise "no input provided, please specify file as command line arg"
  end

  @input ||= $<.map(&:to_s)
  @input = input.map(&:strip) if strip_newlines
  @input = @input[0] if @input.length == 1
  @input.dup # prevents alterations to source
end

def read_stdin_char
  begin
    # save previous state of stty
    old_state = `stty -g`
    # disable echoing and enable raw (not having to press enter)
    system "stty raw -echo"
    c = STDIN.getc.chr
    # gather next two characters of special keys
    if(c=="\e")
      extra_thread = Thread.new{
        c = c + STDIN.getc.chr
        c = c + STDIN.getc.chr
      }
      # wait just long enough for special keys to get swallowed
      extra_thread.join(0.00001)
      # kill thread so not-so-long special keys don't wait on getc
      extra_thread.kill
    end
  rescue => ex
    puts "#{ex.class}: #{ex.message}"
    puts ex.backtrace
  ensure
    # restore previous state of stty
    system "stty #{old_state}"
  end
  return c
end

def part(num, &block)
  puts "Part #{num.to_s}:".green; yield; puts ""
end
# Advent Boilerplate End
