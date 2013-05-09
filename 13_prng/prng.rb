#!/usr/bin/env ruby

# This class will contain every case
class PRNGCase

	# constructor builds the instance from input
	def initialize( i )

		# the test number (to be outputed later)
		@i = i

		# n = number of elements in the sequence (unused)
		# m = number of pairs tested
		@n,@m = gets.chomp.split(' ').map( &:to_i )

		# sequence will contain the list of numbers
		# we store them as strings to avoid computing the value (comparing equality is the same)
		@sequence = gets.chomp.split(' ')

		# sub_sequence_idx will contain the list...
		@sub_sequence_idx = @m.times.map do

			# of pairs to be evaluated
			gets.chomp.split(' ').map( &:to_i )
		end

		# compute the cache before ending the constructor
		compute_cache
	end

	# this function computes the cache of equality (to avoid compare the same numbers again and again)
	def compute_cache

		# cache of equality will be stored on @equals
		# we store if a number if equal to the successor
		@equals = Array.new( @sequence.size )

		# for every number on the list
		i = 0
		@sequence.reduce do |left,right|

			# We compute and store the equality
			@equals[i] = ( left === right )

			# next number!!!
			i += 1

			# we return right to continue the reduce
			right
		end

		# The last number is NOT equal to the successor
		@equals[ i ] = false
	end

	# This function will output the result
	def print_solution

		# The first, the number of test case
		puts "Test case \##{@i}"

		# For every pair to be tested
		@sub_sequence_idx.each do |s,e|

			# the maximum number of coincidences is stored on max
			max = 0

			# the current number of coincidences in a row is stored on coincidences_on_a_row
			coincidences_on_a_row = 0

			# From start of the range
			i = s - 1

			# Until the end of it (please note the index of s,e is 1-based)
			while i < e - 1

				# if there is a coincidence
				if @equals[ i ]

					# we inc the counter
					coincidences_on_a_row += 1

				# if the coincidences stop...
				elsif coincidences_on_a_row > 0

					# we store the maximum
					max = [ coincidences_on_a_row, max ].max

					# and reset the counter
					coincidences_on_a_row = 0
				end

				# next number!!
				i += 1
			end

			# in case of coincidences found at the end of the range, update the max before...
			max = [ coincidences_on_a_row, max ].max

			# ...before print it. Please note that we compute equalities
			#  but problem asks us for numbers-equals-in-a-row, so we need to sum 1
			puts max + 1
		end
	end

end

# First line is the number of test cases
t = gets.chomp.to_i

# Starting at 1 and ending at T
(1..t).each do |i|

	# Read a case and print the solution
	PRNGCase.new( i ).print_solution

end


