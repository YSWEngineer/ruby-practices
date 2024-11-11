#!/usr/bin/env ruby
require 'date'
require 'optparse'

today = Date.today
year = today.year
month = today.month

opt = OptionParser.new
opt.on('-m MONTH', Integer) {|v| month = v }
opt.on('-y YEAR', Integer) {|v| year = v }
opt.parse!(ARGV)

puts "#{month}月 #{year}".center(20)

puts "日 月 火 水 木 金 土"

first_day = Date.new(year, month, 1)
last_day = Date.new(year, month, -1)

print "   " * first_day.wday

(first_day..last_day).each do |date|
  print "#{date.day.to_s.rjust(2)} "
  puts if date.saturday?
end

puts

