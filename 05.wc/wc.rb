# frozen_string_literal: true

# !/usr/bin/env ruby

def print_count(value, option_char, option_str)
  print value.to_s.rjust(8) if option_str.empty? || option_str.include?(option_char)
end

def print_counts(lines, words, bytes, option_str, filename = nil)
  [
    [lines, 'l'],
    [words, 'w'],
    [bytes, 'c']
  ].each do |value, option_char|
    print_count(value, option_char, option_str)
  end
  print " #{filename}" if filename
  print "\n"
end

def process_stdin(option_str)
  content = $stdin.read
  lines = content.lines.count
  words = content.split.size
  bytes = content.bytesize
  print_counts(lines, words, bytes, option_str)
end

def process_file(filename)
  content = File.read(filename)
  lines = content.lines.count
  words = content.split.size
  bytes = content.bytesize
  [lines, words, bytes]
end

def process_files(filenames, option_str)
  total_lines = 0
  total_words = 0
  total_bytes = 0

  filenames.each do |filename|
    lines, words, bytes = process_file(filename)
    total_lines += lines
    total_words += words
    total_bytes += bytes

    print_counts(lines, words, bytes, option_str, filename)
  end

  print_counts(total_lines, total_words, total_bytes, option_str, 'total') if filenames.size > 1
end

def main
  options, filenames = ARGV.partition { |arg| arg.start_with?('-') }
  option_str = options.join

  if filenames.empty?
    process_stdin(option_str)
  else
    process_files(filenames, option_str)
  end
end

main
