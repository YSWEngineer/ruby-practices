#!/usr/bin/env ruby
# frozen_string_literal: true

scores = ARGV[0].split(',')
shots = scores.map { |score| score == 'X' ? 10 : score.to_i }

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

total_score = 0

frames.take(10).each_with_index do |frame, i|
  next_frame = frames[i + 1]
  frame_after_next = frames[i + 2]

  if frame[0] == 10
    total_score += next_frame.size == 1 ? 10 + next_frame.sum + frame_after_next[0] : 10 + next_frame.take(2).sum
  elsif frame.sum == 10
    total_score += 10 + next_frame.first
  else
    total_score += frame.sum
  end
end

puts total_score
