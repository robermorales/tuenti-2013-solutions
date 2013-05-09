#!/usr/bin/env ruby

# This class represent every case of the input
class Scenario

	# Builds a Scenario from input
	def initialize

		# Every scenario consists of a pair M,N
		@m,@n = gets.chomp.split(',').map(&:to_i)

		# the initial position on the grid
		@x,@y = gets.chomp.split(',').map(&:to_i)

		# number of seconds available
		@z = gets.chomp.to_i

		# number of gems
		@g = gets.chomp.to_i

		# a list of gems separated by '#'
		@gems = gets.chomp.split('#').map do |gem|
			
			# i,j,k (position and value of every gem)
			i,j,k = gem.split( ',' ).map( &:to_i )

		end

		# we store them sorted by value, for speed up the algorithm
		@gems.sort! do |gem|
			i,j,k = gem
			k
		end

		# we have a cache to avoid computing the same twice
		@cache = {}
	end

	# This method compute the maximum value of gems, invoking the first call of a backtracking method
	def max_gems
		search_for_gems( @x, @y, @x, @y, 0, 0, [], (0..@g-1).to_a, @z )
	end

	# This method test if the path from (prev_a,prev_b) --> (a,b) --> (target_a,target_b)
	#  requires a detour since it is the same b-coordinate (row or column), and the a-coordinate requires a reversal
	def self.require_detour( a, prev_a, target_a, b, prev_b, target_b )
		# To test for the reversal, we compute the distance from prev to a, and from target to a.
		# --> if both are the same sign, multiplying them will be greater than 0
		( b == target_b ) and ( b == prev_b ) and ( prev_a - a ) * ( target_a - a ) > 0
	end

	# This method is a recursive backtracking
	#  x,y                           represent the current point
	#  prev_x,prev_x                 are coordinates the last position (useful for computing slow reversals)
	#  current                       is the value already taken
	#  max_other_ways                is the running maximun, useful to cut the algorithm when it is unreachable
	#  index_taken, index_remaining  represent the index of collected and available gems
	def search_for_gems( x, y, prev_x, prev_y, current, max_other_ways, index_taken, index_remaining, seconds_remaining )
		
		# if there is no time or no gems available, return current
		if seconds_remaining <= 0 or index_remaining.empty?
			current
		else
			# Before computing, test if the result is already in the cache.
			# If not, computes it, stores it in the cache, and returns it
			# The cache is indexed by
			#   the number of seconds remaining
			#   the gems taken
			#   the last gem (that determine the last position)
			@cache[[seconds_remaining,index_taken.sort,index_taken.last]] ||=

				# We iterate over remaining gems searching for a max
				index_remaining.reduce( max_other_ways ) do |max, next_gem|

					# read i,j,k of the next gem
					i,j,k = @gems[ next_gem ]

					# manhattan distance between current position and gem position
					seconds_required = ( x - i ).abs + ( y - j ).abs

					# test if reversal needed (we add 2 extra steps to change direction)
					if  Scenario.require_detour( x, prev_x, i, y, prev_y, j ) or
						Scenario.require_detour( y, prev_y, j, x, prev_x, i )
						seconds_required += 2
					end

					# We compute the new value for the input "seconds_remaining"
					new_seconds_remaining = seconds_remaining - seconds_required

					# We compute the new value for the input "current"
					new_current = current + k

					# We test for an unreachable max:
					#  if taking a 5-value gem every new second is not enough, stop searching
					if( new_current + ( 5 * new_seconds_remaining ) <= max )
						max
					else
						# We invoke search_for_gems recursively
						max_this_way = search_for_gems(
							# the new position is the position of the gem
							i, j,

							# the prev position (to compute reversals)
							x, y,

							# the new current value
							new_current,

							# the running max
							max,

							# modify the array of taken adding the next_gem
							index_taken + [ next_gem ],

							# deleting it from the available ones
							index_remaining.reject{|n|n==next_gem},

							# the new value of seconds_remaining
							new_seconds_remaining
						)

						# We return the max between the running maximum and the just-computed value
						[ max_this_way, max ].max
					end
				end
		end
	end
	
end

# The first line is the number of cases
t = gets.chomp.to_i

# every case
t.times do

	# we build a scenario from input, and output the maximum number of gem value
	puts Scenario.new.max_gems
end
