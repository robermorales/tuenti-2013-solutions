#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# This problem has two parts
# 1. searching for valid words and value them
# 2. optimize a sum of values under a maximum weight (knapsack!)

# This constant identifies the end of a word in the tree that we are building with the dict
ENDWORD = '.'

# This class stores a singleton dictionary with the words
# Example, if the dictionary contains only PI, PIP, PO; the dict is
# { 'P' => { 'I' => { ENDWORD => {}, 'P' => { ENDWORD => {} } }, 'O' => { ENDWORD => {} } } }
# This schema allows for constant time comparing if a new character forms a new word,
#  or if a current list of chars is a complete word.
class Dict

	# This attr contains the schema explained
	attr_reader :words

	# singleton
	def self.get_instance
		@@DICT ||= Dict.new
	end

	# This constructor builds from input
	def initialize
		@words = {}

		# for every line of the dict
		File.readlines( "boozzle-dict.txt" ).each do |line|

			# word is the line without the \n
			word = line.chomp

			# we start at the top of the tree
			path = @words

			# for each char of the word
			word.split('').each do |char|

				# we are traversing the tree, and creating nodes if needed
				path = path[ char ] ||= {}
			end

			# we mark the end of a word
			path[ ENDWORD ] = {}
		end
	end
end

# Algorithms of knapsack use this two structs
KnapsackItem = Struct.new(:name, :cost, :value)
KnapsackProblem = Struct.new(:items, :max_cost)

# This class represent each scenary
class Boozzle

	# Constructor builds from input
	def initialize

		# To store scores, we build a hash using a plain pair array [['a',3],['b',1]]...
		# To get this plain array, we split the input at commas
		@scores = Hash[gets.chomp.split(',').map do |pair|
				# and then split for the rest of characters, deleting empty parts
				k, v = pair.split( /[\:,{}\"\'\s]/ ).reject{ |ch| ch=='' }
				[ k, v.to_i ]
			end]

		# Input follows with the number of seconds
		@seconds = gets.chomp.to_i

		# The height
		@n = gets.chomp.to_i

		# and the width of the matrix
		@m = gets.chomp.to_i

		# matrix is read line by line
		@map = @n.times.map do |row|
			# and, then, cell by cell
			gets.chomp.split(' ').map do |cell|
				# Each cell is represented by Wxy where W represents the character,
				#  x is the multiplier type and y is the multiplier value
				ch,x,y = cell.split('')
				# If x=1 (CM multiplier) then CM(ci) = y, WM(ci) = 1, 1 ≤ y ≤ 3
				# If x=2 (WM multiplier) then CM(ci)=1, WM(ci) = y, 1 ≤ y ≤ 3
				x.to_i == 1 ? [ ch, y.to_i, 1 ]: [ ch, 1, y.to_i ]
			end
		end

		# This hash will represent the words available on the matrix
		@cache_words = {}
		@n.times do |new_y|
			@m.times do |new_x|
				# We add new words to the list from every possible starting point
				compute_cache_words( [@map[new_y][new_x]], [[new_x,new_y]], Dict.get_instance.words[@map[new_y][new_x][0]] )
			end
		end
	end

	# This method add words to the list of words following the already taken cells (chars_taken)
	#  and the already taken positions (positions_taken)
	def compute_cache_words( chars_taken, positions_taken, dict_current_pos )
		# if the word cant exist with this chars dict_current_pos will be nil
		return unless dict_current_pos

		# starting point 
		pos_x,pos_y = positions_taken.last
		
		# variations in the collindant cells of starting point, cut by the limits of the matrix
		var_y = ( [ pos_y - 1, 0 ].max .. [ pos_y + 1, @n - 1 ].min )
		var_x = ( [ pos_x - 1, 0 ].max .. [ pos_x + 1, @m - 1 ].min )

		# for each cell around the starting point
		var_x.each do |new_x|
			var_y.each do |new_y|

				# There is two possibilities:
				# 1. it is not the same cell, so we can add it to the movement
				if [new_x,new_y] != [pos_x,pos_y]
					
					# we test if the position is already taken!
					if ( not positions_taken.include? [new_x,new_y] )

						# we get the character and modifiers from matrix
						new_char,cm,wm = @map[new_y][new_x]

						# we search in the dictionary if the path is possible
						next_step = dict_current_pos[ new_char ]

						# if it is
						if next_step

							# we going further adding this cell to the current movement
							compute_cache_words(chars_taken + [[new_char,cm,wm]],
												positions_taken + [[new_x,new_y]],
												next_step )
						end
					end
					
				# 2. is the same cell
				#   --- we use this case to test for a complete word
				elsif dict_current_pos[ ENDWORD ]

						# the word is the join of the characters
						new_word = chars_taken.map{|ch,cm,wm| ch }.join

						# the value is computed by an util function
						new_value = compute_value(chars_taken)

						# we store the new word as a key in a hash,
						#  with the maximum value possible for it
						#  (we are supported by the fact that one word only will be taken at max once, by rules)
						old_value = @cache_words[ new_word ]
						if  old_value
							@cache_words[ new_word ] = [ old_value, new_value ].max
						else
							@cache_words[ new_word ] = new_value
						end
				end
			end
		end
	end

	# This is the method that computes what problem asks for
	def max_score

		# We store every word as a knapsack item
		items = @cache_words.map do |word,value|
			# weight is the size + 1 (1 second is required for every cell, and for submit the word)
			# value is the computed value for the word
			KnapsackItem.new( word, word.size+1, value )
		end

		# We build a knapsack problem with the restriction on weight: seconds
		problem = KnapsackProblem.new(items, @seconds)

		# invoke the algorith
		cost_matrix = dynamic_programming_knapsack( problem )

		# returns the total value
		cost_matrix.last.last
	end

	# This useful function computes the value of a chain of cells
	def compute_value( chars_taken )
		# Maximum of word modifiers
		max_wm = chars_taken.map{ |ch,cm,wm| wm }.max

		# Sum of scores*char modifiers
		c = chars_taken.map do |ch,cm,wm|
			@scores[ch] * cm
		end.reduce( &:+ )

		# Base * WM + J (j=size)
		c * max_wm + chars_taken.size
	end

	# This function computes a knapsack solutions using dynamic programming
	# (it returns the full cost_matrix where we can find the useful info we want)
	def dynamic_programming_knapsack(problem)
		num_items = problem.items.size
		items = problem.items
		max_cost = problem.max_cost
		
		cost_matrix = zeros(num_items, max_cost+1)
		
		num_items.times do |i|
			(max_cost + 1).times do |j|
				if(items[i].cost > j)
					cost_matrix[i][j] = cost_matrix[i-1][j]
				else
					cost_matrix[i][j] = [cost_matrix[i-1][j], items[i].value + cost_matrix[i-1][j-items[i].cost]].max
				end
			end
		end
		
		cost_matrix
	end

	# This function is used by knapsack algorith, only for clarity of the code
	def zeros(rows, cols)
		Array.new(rows) do |row|
			Array.new(cols, 0)
		end
	end
end

# The first line is the number of cases
t = gets.chomp.to_i

# for every case
t.times.map do

	# we build a Boozzle, computes the solution, and outputs the result
	puts Boozzle.new.max_score
end
