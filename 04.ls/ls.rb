# frozen_string_literal: true

# !/usr/bin/env ruby
require 'optparse'

show_hidden = false

opt = OptionParser.new
opt.on('-a') do
  show_hidden = true
end

opt.parse!(ARGV)

files =
  if show_hidden
    Dir.glob('*', File::FNM_DOTMATCH)
  else
    Dir.glob('*')
  end

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
