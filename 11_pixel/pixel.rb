#!/usr/bin/env ruby

# This program generates the images from the island signals

require 'chunky_png'

# Size is exponent of 4 since images are indicated as quadrants
SIZE = 4**4

# NE, NW, SW, SE (it is the orden of image filling, in [x,y] pairs)
VARS = [[1,-1],[-1,-1],[-1,1],[1,1]]

# This class represent each image, as a list of summed squares
class SquareList

	# Constructor from line (several squares) and the filename to be saved
	def initialize( lines, filename )

		# We start creating the image
		@png = ChunkyPNG::Image.new(SIZE, SIZE, ChunkyPNG::Color('white'))

		# For every square
		@squares = lines.split(' ').each_with_index do |sq_line,sq_i|

			# the line is to be reordered from sq_line to line
			# line will be in the form [b[bbbb]bb] representing
			#       p
			#    ___|_
			#   / / | \
			#   b p b b
			#    _|
			#   //|\
			#   bbbb

			# This four variables is for iterating sq_line
			line = ''
			i = 0
			len = sq_line.size
			positions = []

			# until the end of sq_line
			while i < len

				# if there is no 'p' positions in the previous level, start looking for them!
				if positions.empty?

					# For every character of the line representing the previous level
					line.split('').each_with_index do |ch,li|

						# if it is a 'p'
						if ch == 'p'

							# store the position
							positions << li
						end
					end
				end

				# if there are no 'p's in the previous level (first level?)
				if positions.empty?

					# sublevel starts at pos 0
					positions << 0
					i += 1
				end

				# this variable is for incrementing the positions since during replacement they are displaced
				offset = 0

				# For each 'p' in the previous level
				positions.each do |li|

					# we replace this 'p' for the sublevel of that node (the next 4 chars)
					line[ li + offset ] = "[#{sq_line[i,4]}]"

					# position of next 'p' displaced 5 positions (6 of [xxxx] minus 1 'p')
					offset += 5

					# next block is 4 bytes ahead
					i += 4
				end

				# We clean the positions array for the next iteration
				positions = []
			end

			# We build an image using the computed line
			# We pass the line, starting at 0, starting at center (SIZE/2,SIZE/2) and with a radius of SIZE/2
			fill_image( line, 0, SIZE/2, SIZE/2, SIZE/2 )
		end

		# We save the image built in the file whose name we receive by params
		@png.save( filename )
	end

	# This function builds an image using 'chunky_png'
	# Image was started with a white background, we only need to paint black squares
	def fill_image( line, i, cx, cy, r )

		# starting at i, the current char is read
		char = line[i]

		# next i is computed
		current_i = i + 1

		# there are two options

		# 1. it is a sublevel
		if char == '['

			# we compute the four directions
			VARS.each do |vx,vy|

				# the new center and radius for every direction
				new_cx,new_cy,new_r = [ cx + vx * r / 2, cy + vy * r / 2, r / 2 ]

				# and the recursive call for each quadrant
				current_i = fill_image( line, current_i, new_cx, new_cy, new_r )
			end

			# we skip the ']' character
			current_i += 1

		# 2. it is a black
		elsif char == 'b'

			# we build a square (from cx-r,cy-r to cx+r-1,cy+r-1)
			(cx-r..cx+r-1).each do |x|
				(cy-r..cy+r-1).each do |y|
					
					# To set the pixels black
					@png[x,y] = ChunkyPNG::Color('black')
				end
			end
		end

		# and return the current positions in case of recursive calls to process the same line
		current_i
	end

end

# Input start with the number of cases
t = gets.chomp.to_i

# for every case,
t.times do |ti|

	# Builds a square list and save the image on a file
	SquareList.new( gets.chomp, "#{ti}.png" )
end
