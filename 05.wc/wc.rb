# frozen_string_literal: true

# !/usr/bin/env ruby

require 'optparse'

def main
  options, filenames = parse_arguments
  if filenames.empty?
    display_stdin_counts(options)
  else
    display_file_counts(filenames, options)
  end
end

def parse_arguments
  options = {}
  opt = OptionParser.new
  opt.on('-l') { options[:lines] = true }
  opt.on('-w') { options[:words] = true }
  opt.on('-c') { options[:bytes] = true }
  opt.parse!(ARGV)
  [options, ARGV]
end

def display_stdin_counts(options)
  content = $stdin.read
  counts = count_content(content)
  display_counts(counts, options)
end

def display_file_counts(filenames, options)
  total = { lines: 0, words: 0, bytes: 0, name: 'total' }
  filenames.each do |filename|
    counts = count_from_file(filename)
    total[:lines] += counts[:lines]
    total[:words] += counts[:words]
    total[:bytes] += counts[:bytes]
    display_counts(counts, options)
  end
  display_counts(total, options) if filenames.size > 1
end

def count_from_file(filename)
  content = File.read(filename)
  count_content(content, filename)
end

def count_content(content, name = nil)
  {
    lines: content.lines.count,
    words: content.split.size,
    bytes: content.bytesize,
    name: name
  }
end

def display_counts(counts, options)
  %i[lines words bytes].each do |key|
    print format_count(counts[key]) if options.empty? || options[key]
  end
  print " #{counts[:name]}" if counts[:name]
  print "\n"
end

def format_count(value)
  value.to_s.rjust(8)
end

main
