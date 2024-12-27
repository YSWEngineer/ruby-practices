#!/usr/bin/env ruby
# frozen_string_literal: true

score = ARGV[0].split(',')
shots = []

score.each do |s|
  shots << (s == 'X' ? 10 : s.to_i)
end

frames = []
current_frame = []

shots.each do |shot|
  current_frame << shot
  if current_frame[0] == 10 || current_frame.size == 2
    frames << current_frame
    current_frame = []
  end
end

frames << current_frame unless current_frame.empty?

point = 0

frames.each_with_index do |frame, i|
  break if i >= 10

  if frame[0] == 10
    point += 10 + frames[i + 1].take(2).sum
    point += frames[i + 2][0] if frames[i + 1]&.size == 1
  elsif frame.sum == 10
    point += 10 + (frames[i + 1]&.first || 0)
  else
    point += frame.sum
  end
end

puts point
