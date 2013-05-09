#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# This problem is a linear optimization with constraints
# Lets do use minizinc, the perfect weapon for this problem!

# We need this wrapper since minizinc cant process input from stdin
# http://www.minizinc.org/download.html

# We need a value for INF since minizinc does not allow expressing it
INFINITY = 999999999

# This class represent every battle
class Battle

	# This constructor builds the battle from the input
	def initialize
		# For each test case, in a single line, whitespace-separated:
		#  Integer W: width of the canyon, in meters
		#  Integer H: length of the canyon, in meters
		#  Integer S: price to train a soldier, in pieces of gold
		#  Integer C: price to trigger a Crematorium, in pieces of gold
		#  Integer G: amount of gold that you have
		@w,@h,@soldier_cost,@crematorium_cost,@gold_available = gets.chomp.split(' ').map{|s|s.to_i}
	end

	# This method invoke minizinc with the input data
	def invoke_mzn( data )
		return '0'
		# We put in the form minizinc expects
		mzn_data = data.collect do |k,v|
			"#{k}=#{v}; "
		end.join

		# We build the command
		# (please see galaxy.mzn file)
		command = "minizinc galaxy.mzn -D '#{mzn_data}' 2>&1"

		# And we executes and returns the first line of the command
		result = %x[ #{command} ]
		puts result
		result.split("\n").first
	end

	# This is the function that outputs the result expected by the test
	# Note that, if INFINITY, we puts "-1"
	def max_seconds
		seconds = invoke_mzn({
		            :w                => @w,
		            :h                => @h,
		            :soldier_cost     => @soldier_cost,
		            :crematorium_cost => @crematorium_cost,
		            :gold_available   => @gold_available,
		            :INFINITY         => INFINITY
		            }).to_i
		seconds == INFINITY ? -1 : seconds
	end

end

# First line is the number of test cases
t = gets.chomp.to_i

t.times do
	# Build a battle from input and outputs the result
	puts Battle.new.max_seconds
end
