#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# Problem is about computing md5 on packed strings
# String size is toooooo long to be unpacked

require 'digest/md5'

# We will store the strings in a semipacked-form
# In this semipacked-form, the sub-strings will be, at max, of 512K
MAX_STRING_SIZE = 512*1024

# This class represent every scenary
class Machine

	# This contructor builds the schema from input and outputs the md5 digest
	def initialize( line )
		
		# This attr stores the md5 incremental builder
		@incr_digest = Digest::MD5.new()

		# This attr stores the schema, builds from 0th-index of the line
		@schema,_ = create_schema( line, 0 )

		# The schema is optimized (semi-unpacked)
		@schema = optimize( @schema )

		# We build the md5 of the schema
		md5(@schema)

		# And puts the md5 digest
		puts @incr_digest.hexdigest
	end

	# This function creates a schema for i-th position of the line
	# Returns the schema created and the current position of the semi-scanned line
	# This is useful to scan one line in recursive calls (for processing the brakets)
	def create_schema( line, i )
		# Schema to be returned
		current_schema = []

		# Word before number before brakets
		current_word   = ''

		# number before brakets
		current_number = ''

		# current position (also to be returned)
		current_i = i

		# current character
		character = nil

		# until the end, (or until a closing braket!)
		while current_i < line.size and character != ']'

			# read one character
			character = line[ current_i ]

			# if alphabetic
			if ('a'..'z').include? character

				# we store it in the current buffer
				current_word   << character

			# if numeric
			elsif ('0'..'9').include? character

				# we store it in the current buffer
				current_number << character

				# after the number, there is no more characters
				if not current_word.empty?

					# populates the schema with the word (with a multiplier of 1)
					current_schema << [ current_word, 1 ]

					# and erases the buffer
					current_word = ''
				end

			# if open-braket, it is the start of a sub_schema
			elsif character == '['

				# invoke recursively
				new_schema,current_i = create_schema( line, current_i + 1 )

				# populates the schema with the sub-schema, and the multiplier we are storing in a buffer
				current_schema << [ new_schema, current_number.to_i ]

				# we erases the buffer of the multiplier
				current_number = ''
			end

			# next char!!!
			current_i += 1
		end

		# after the scan of the line (or a closing braket found)...
		# If it is content in the buffer,
		if not current_word.empty?

			# populates the schema with the part
			current_schema << [ current_word, 1 ]
		end

		# return the computed schema, and the current index
		[current_schema,current_i-1]
	end

	# This function opmitizes (semipacks) a schema
	# Remember that schema has been built using a pairs of sub-schema,multiplier
	def optimize( schema )

		# If it is a string, cant be optimized!
		return schema if schema.class == String

		# If it is a pair of sub-schema,multiplier
		# For every pair...
		new_schema = schema.map do |sub_schema,multiplier|

			# We optimize the sub_schema
			new_sub_schema = optimize( sub_schema )

			# If the optimized sub_schema is a string,
			# Computes the final string (multiplying it), but only if a current max is not reached!
			# This avoids full unpacking, if insane
			if( new_sub_schema.class == String and ( new_sub_schema.size * multiplier < MAX_STRING_SIZE ) )
				new_sub_schema * multiplier

			# If the optimized sub_schema is not a string (or it is impossible to build a string with it)
			elsif multiplier > 1

				# if the only item of the sub_schema is a pair, compact the multipliers
				#        From 3[4[a]]       ----> To 12[a]
				# it is: From [[['a',3]],4] ----> To ['a',12]
				if new_sub_schema.class == Array and new_sub_schema.size == 1
					[ new_sub_schema[0][0], new_sub_schema[0][1] * multiplier ]

				# nothing to do if it has more than one child
				else
					[ new_sub_schema, multiplier ]
				end

			# If the optimized sub_schema is a string, or a pair-array with a multiplier of 1
			# we cannot optimize it more in this loop
			else
				[ new_sub_schema, 1 ]
			end
		end

		# If the schema if a sub-schema array
		if new_schema.class == Array

			# we build a smaller array compacting the values that are strings and are neighbours
			r_schema = []

			# for every sub-schema
			new_schema.each do |sub_schema|

				# if the sub-schema is a string and the last item appended is a string, join them
				if sub_schema.class == String and r_schema.last and r_schema.last.class == String
					r_schema.last << sub_schema

				# else, append to the end of the computed schema
				else
					r_schema << sub_schema
				end
			end

			# replace the new computed schema with the joined
			new_schema = r_schema
		end
		
		# if (after the firsts optimizing loops), all elements are strings, join them
		if new_schema.all? { |a| a.class == String }
			new_schema = new_schema.join

		# IF there is only one pair, with a multiplier of 1, extract the sub-schema
		elsif new_schema.size == 1 and new_schema[0][1] == 1
			new_schema = new_schema[0][0]
		end

		# Return the optimized schema
		new_schema
	end

	# This computes md5 digest of the schema over an attr called incr_digest
	def md5( schema )

		# if the schema is a string, compute directly
		if schema.class == String
			@incr_digest.update( schema )

		# if the schema is a list of sub_schemas, one by one
		else
			schema.each do |sub_schema|

				# if the sub_schema is a array
				if( sub_schema.class == Array )

					# we extract the multiplier first
					real_sub_schema,multiplier = sub_schema

					# to build a loop
					multiplier.times do

						# computing the md5 for the first part
						md5( real_sub_schema )
					end

				# if this item of the array is a string, computes directly
				else
					md5( sub_schema )
				end
			end
		end
	end

end

# every new line is a new case

# for every line
readlines.each do |line|

	# build a machine (constructor reads the input and outputs the result)
	Machine.new( line.chomp )
end
