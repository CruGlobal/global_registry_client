#!/usr/bin/env ruby

$: << '.'
$: << File.join(File.dirname(__FILE__), "../lib")
$: << File.join(File.dirname(__FILE__), "../ext")

require 'oj'

p = Oj::Parser.validate
# p = Oj::Parser.new(:debug)
p.parse(%|{|)
