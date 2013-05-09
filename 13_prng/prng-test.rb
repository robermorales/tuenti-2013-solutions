#!/usr/bin/env ruby

# This file outputs a test case reaching the limits to test the main program

T = 5
N = 10**6
M = 10**4

puts T

T.times do
	i = 0
	puts "#{N} #{M}"
	N.times do
		print "#{i} "
		i += 1 if rand > 0.5
	end
	puts
	M.times do
		s = rand(M)
		e = s + rand(M-s)
		puts "#{s} #{e}"
	end
end
