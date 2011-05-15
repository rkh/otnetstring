#!/usr/bin/env ruby -I lib -I vendor/tnetstring-rb/lib
require 'otnetstring'
require 'tnetstring'
require 'benchmark'
require 'stringio'

class SlowStream
  def initialize(str)
    @length = str.length
    @io     = StringIO.new(str)
  end

  def readchar
    slow_down
    @io.readchar
  end

  def read(n)
    slow_down(n)
    @io.read(n)
  end

  def to_s
    read(@length)
  end

  def split(*args)
    to_s.split(*args)
  end

  def pos
    @io.pos
  end

  def slow_down(times = 1)
    # simulating network with 3 GBit/sec!
    sleep(2.0e-08 * times)
  end
end

def report(x, desc, *objects)
  [TNetstring, OTNetstring].each do |type|
    input = objects.map { |e| type.encode(e) }
    x.report("#{type}: #{desc}") do
      input.each { |data| type.parse(block_given? ? yield(data) : data) }
    end
  end
end

Benchmark.bmbm do |x|
  simple = [0, nil, true, false, 42, {}, [], "hi"]
  nested = simple
  large  = "x"*99999999
  3.times do
    nested = {'a' => nested }
    1.upto(5000).each { |i| nested[i.to_s] = simple }
  end

  report(x, "simple objects", *simple)
  report(x, "long string", large)
  report(x, "flat arrays", simple*5000)
  report(x, "complex nesting", nested)
  report(x, "with remainder", simple) { |e| e << large }
  report(x, "streaming (3 GBit/sec)", simple*5000) { |e| SlowStream.new(e) }
  report(x, "streaming (3 GBit/sec), with remainder", simple) { |e| SlowStream.new(e << large) }
end
