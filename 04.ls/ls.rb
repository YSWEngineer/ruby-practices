# frozen_string_literal: true

# !/usr/bin/env ruby
require 'optparse'

show_hidden = false

opt = OptionParser.new
opt.on('-a') do
  show_hidden = true
end

opt.parse!(ARGV)

files = Dir.entries('.').reject { |file| ['.', '..'].include?(file) }
files = files.reject { |file| file.start_with?('.') } unless show_hidden
files = files.sort

COLUMNS = 3
rows = (files.size.to_f / COLUMNS).ceil

def max_length(files)
  (files.map(&:length).max || 0) + 1
end

def build_line(files, row, rows, columns, max_length)
  line = ''

  columns.times do |column|
    index = row + column * rows
    name = files[index] || ''
    line += name.ljust(max_length)
  end

  line
end

def print_rows(files, rows, columns, max_length)
  rows.times do |row|
    puts build_line(files, row, rows, columns, max_length)
  end
end

print_rows(files, rows, COLUMNS, max_length(files))
