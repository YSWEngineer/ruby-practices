# frozen_string_literal: true

# !/usr/bin/env ruby

files = Dir.glob('*').sort
columns = 3
rows = (files.size.to_f / columns).ceil

def max_length(files)
  files.map(&:length).max + 1
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
    line = build_line(files, row, rows, columns, max_length)
    puts line
  end
end

print_rows(files, rows, columns, max_length(files))
