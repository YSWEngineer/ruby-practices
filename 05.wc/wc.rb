# frozen_string_literal: true

# !/usr/bin/env ruby

def print_count(value, option_char, option_str)
  print value.to_s.rjust(8) if option_str.empty? || option_str.include?(option_char)
end

options, filenames = ARGV.partition { |arg| arg.start_with?('-') }
option_str = options.join

total_lines = 0
total_words = 0
total_bytes = 0

if filenames.empty?
  content = $stdin.read
  lines = content.lines.count
  words = content.split.size
  bytes = content.bytesize

  [
    [lines, 'l'],
    [words, 'w'],
    [bytes, 'c']
  ].each do |value, option_char|
    print_count(value, option_char, option_str)
  end
  print "\n"
else
  filenames.each do |filename|
    content = File.read(filename)
    lines = content.lines.count
    total_lines += lines

    words = content.split.size
    total_words += words

    bytes = content.bytesize
    total_bytes += bytes

    [
      [lines, 'l'],
      [words, 'w'],
      [bytes, 'c']
    ].each do |value, option_char|
      print_count(value, option_char, option_str)
    end
    print " #{filename}"
    print "\n"
  end

  if filenames.size > 1
    [
      [total_lines, 'l'],
      [total_words, 'w'],
      [total_bytes, 'c']
    ].each do |value, option_char|
      print_count(value, option_char, option_str)
    end
    print ' total'
    print "\n"
  end
end
