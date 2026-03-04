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

if show_long
  stats = files.map { |f| File.lstat(f) }

  total_blocks = stats.sum(&:blocks)
  puts "total #{total_blocks}"

  nlink_width = stats.map { |s| s.nlink.to_s.length }.max
  size_width = stats.map { |s| s.size.to_s.length }.max

  files.each_with_index do |path, i|
    stat = stats[i]
    type = FTYPE_TO_CHAR[stat.ftype] || '?'
    perm = permission_string(stat.mode)

    puts [
      "#{type}#{perm}",
      stat.nlink.to_s.rjust(nlink_width),
      Etc.getpwuid(stat.uid).name,
      Etc.getgrgid(stat.gid).name,
      stat.size.to_s.rjust(size_width),
      stat.mtime.strftime('%b %e %H:%M'),
      path
    ].join(' ')
  end
else
  COLUMNS = 3
  rows = (files.size.to_f / COLUMNS).ceil
  print_rows(files, rows, COLUMNS, max_length(files))
end
