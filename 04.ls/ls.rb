# frozen_string_literal: true

# !/usr/bin/env ruby
require 'optparse'

show_hidden = false
reverse = false

opt = OptionParser.new
opt.on('-a') { show_hidden = true }
opt.on('-r') { reverse = true }

opt.parse!(ARGV)

flags = show_hidden ? File::FNM_DOTMATCH : 0
files = Dir.glob('*', flags)

files = files.sort
files = files.reverse if reverse

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
