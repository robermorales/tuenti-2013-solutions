#!/usr/bin/env ruby

# An index file is generated using missing.cpp,
#  with the command `make missing && ./missing > missing-list.txt`

# This program only search for the nth lines of that file

# The first line is the number of cases
t = gets.chomp.to_i

# every case
t.times do
	# consists of a number N
	n = gets.chomp.to_i

	# indicating the position of the number we are searching for
	puts `sed -n '#{n}p;' missing-list.txt`
end


