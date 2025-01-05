#!/usr/bin/env ruby
# frozen_string_literal: true

shots = ARGV[0].split(',').map { |shot| shot == 'X' ? 10 : shot.to_i }

current_frame = []
frames = [current_frame]

shots.each do |shot|
  current_frame << shot
  if current_frame[0] == 10 || current_frame.size == 2
    current_frame = []
    frames << current_frame
  end
end

frames << current_frame unless current_frame.empty?

total_score = frames.take(10).each_with_index.sum do |frame, i|
  next_frame = frames[i + 1] || []
  after_next_frame = frames[i + 2] || []

  if frame.first == 10
    following_shots = next_frame + after_next_frame
    10 + following_shots.take(2).sum
  elsif frame.sum == 10
    10 + next_frame.first
  else
    frame.sum
  end
end

puts total_score
