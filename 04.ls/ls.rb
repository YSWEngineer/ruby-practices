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

PERMISSION_TABLE = {
  '0' => '---', '1' => '--x', '2' => '-w-', '3' => '-wx',
  '4' => 'r--', '5' => 'r-x', '6' => 'rw-', '7' => 'rwx'
}.freeze

def permission_string(mode)
  perm = mode.to_s(8)[-3, 3]
  perm.chars.map { |n| PERMISSION_TABLE[n] }.join
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

def file_mode_string(stat)
  type = FTYPE_TO_CHAR[stat.ftype] || '?'
  "#{type}#{permission_string(stat.mode)}"
end

def file_metadata(files)
  files.map do |f|
    stat = File.lstat(f)
    {
      mode: file_mode_string(stat),
      nlink: stat.nlink.to_s,
      user: Etc.getpwuid(stat.uid).name,
      group: Etc.getgrgid(stat.gid).name,
      size: stat.size.to_s,
      mtime: stat.mtime.strftime('%b %e %H:%M'),
      name: f
    }
  end
end

def widths(metadata)
  {
    nlink: metadata.map { |m| m[:nlink].length }.max,
    user: metadata.map { |m| m[:user].length }.max,
    group: metadata.map { |m| m[:group].length }.max,
    size: metadata.map { |m| m[:size].length }.max
  }
end

def print_long_format(files)
  metadata = file_metadata(files)
  total = metadata.sum { |m| File.lstat(m[:name]).blocks }
  puts "total #{total}"
  w = widths(metadata)
  metadata.each do |m|
    puts [
      m[:mode],
      m[:nlink].rjust(w[:nlink]),
      m[:user].ljust(w[:user]),
      m[:group].ljust(w[:group]),
      m[:size].rjust(w[:size]),
      m[:mtime],
      m[:name]
    ].join(' ')
  end
end

if show_long
  print_long_format(files)
else
  COLUMNS = 3
  rows = (files.size.to_f / COLUMNS).ceil
  print_rows(files, rows, COLUMNS, max_length(files))
end
