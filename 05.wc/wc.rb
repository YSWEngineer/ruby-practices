# frozen_string_literal: true

# !/usr/bin/env ruby

require 'optparse'

def main
  options = {}

  opt = OptionParser.new
  opt.on('-l') { options[:l] = true }
  opt.on('-w') { options[:w] = true }
  opt.on('-c') { options[:c] = true }
  opt.parse!(ARGV)

  filenames = ARGV

  if filenames.empty?
    process_stdin(options)
  else
    process_files(filenames, options)
  end
end

def print_count(value)
  print value.to_s.rjust(8)
end

def print_counts(counts, options, filename = nil)
  [
    [counts[:lines], 'l'],
    [counts[:words], 'w'],
    [counts[:bytes], 'c']
  ].each do |value, option_char|
    print_count(value) if options.empty? || options[option_char.to_sym]
  end
  print " #{filename}" if filename
  print "\n"
end

def count_content(content)
  {
    lines: content.lines.count,
    words: content.split.size,
    bytes: content.bytesize
  }
end

def process_stdin(options)
  content = $stdin.read
  counts = count_content(content)
  print_counts(counts, options)
end

def process_file(filename)
  content = File.read(filename)
  count_content(content)
end

def process_files(filenames, options)
  total = { lines: 0, words: 0, bytes: 0 }

  filenames.each do |filename|
    counts = process_file(filename)
    total[:lines] += counts[:lines]
    total[:words] += counts[:words]
    total[:bytes] += counts[:bytes]

    print_counts(counts, options, filename)
  end

  print_counts(total, options, 'total') if filenames.size > 1
end

main
