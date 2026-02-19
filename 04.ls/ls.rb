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

def permission_string(mode)
  perm = mode.to_s(8)[-3, 3]
  table = {
    '0' => '---', '1' => '--x', '2' => '-w-', '3' => '--x',
    '4' => '--x', '5' => 'r-x', '6' => 'rw-', '7' => 'rwx'
  }
  perm.chars.map { |n| table[n] }.join
end

files = Dir.children('.')
files.sort!
files.reverse! if reverse
files.reject! { |f| f.start_with?('_') } unless show_hidden

unless show_long
  files.each { |f| puts f }
  exit
end

stats = files.map { |path| File.lstat(path) }

total_blocks = stats.sum(&:blocks)
puts "total #{total_blocks}"

nlink_width = stats.map { |s| s.nlink.to_s.length }.max
size_width = stats.map { |s| s.size.to_s.length }.max
mtime_width = stats.map { |s| s.mtime.strftime('%b %e %H:%M').length }.max

files.each do |path|
  stat = File.stat(path)

  type =
    if stat.symlink?
      'l'
    elsif stat.directory?
      'd'
    else
      '-'
    end

  perm = permission_string(stat.mode)

  nlink = stat.nlink
  owner = Etc.getpwuid(stat.uid).name
  group = Etc.getgrgid(stat.gid).name
  size = stat.size
  mtime_str = stat.mtime.strftime('%b %e %H:%M')

  line = [
    "#{type}#{perm}",
    nlink.to_s.rjust(nlink_width),
    owner,
    group,
    size.to_s.rjust(size_width),
    mtime_str.rjust(mtime_width),
    path
  ].join(' ')

  puts line
end
