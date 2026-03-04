# frozen_string_literal: true

# !/usr/bin/env ruby
require 'optparse'
require 'etc'

show_hidden = false
reverse = false
show_long = false

opt = OptionParser.new
opt.on('-a') { show_hidden = true }
opt.on('-r') { reverse = true }
opt.on('-l') { show_long = true }

opt.parse!(ARGV)

flags = show_hidden ? File::FNM_DOTMATCH : 0
files = Dir.glob('*', flags)
files = files.sort
files = files.reverse if reverse

FTYPE_TO_CHAR = {
  'file' => '-',
  'directory' => 'd',
  'characterSpecial' => 'c',
  'blockSpecial' => 'b',
  'fifo' => 'p',
  'link' => 'l',
  'socket' => 's'
}.freeze

def permission_string(mode)
  perm = mode.to_s(8)[-3, 3]
  table = {
    '0' => '---', '1' => '--x', '2' => '-w-', '3' => '-wx',
    '4' => 'r--', '5' => 'r-x', '6' => 'rw-', '7' => 'rwx'
  }
  perm.chars.map { |n| table[n] }.join
end

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

def fetch_stats(files)
  files.map { |f| File.lstat(f) }
end

def print_total(stats)
  puts "total #{stats.sum(&:blocks)}"
end

def file_mode_string(stat)
  type = FTYPE_TO_CHAR[stat.ftype] || '?'
  "#{type}#{permission_string(stat.mode)}"
end

def long_format_fields(path, stat, nlink_width, size_width)
  [
    file_mode_string(stat),
    stat.nlink.to_s.rjust(nlink_width),
    Etc.getpwuid(stat.uid).name,
    Etc.getgrgid(stat.gid).name,
    stat.size.to_s.rjust(size_width),
    stat.mtime.strftime('%b %e %H:%M'),
    path
  ]
end

def build_long_line(path, stat, nlink_width, size_width)
  long_format_fields(path, stat, nlink_width, size_width).join(' ')
end

def column_widths(stats)
  nlink_width = stats.map { |s| s.nlink.to_s.length }.max
  size_width = stats.map { |s| s.size.to_s.length }.max
  [nlink_width, size_width]
end

def print_long_format(files)
  stats = fetch_stats(files)
  print_total(stats)
  nlink_width, size_width = column_widths(stats)
  files.each_with_index do |path, i|
    puts build_long_line(path, stats[i], nlink_width, size_width)
  end
end

if show_long
  print_long_format(files)
else
  COLUMNS = 3
  rows = (files.size.to_f / COLUMNS).ceil
  print_rows(files, rows, COLUMNS, max_length(files))
end
