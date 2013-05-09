#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# This class represent the Edge of a graph
class Edge
	attr_accessor :src, :dst, :length
	
	def initialize(src, dst, length = 1)
		@src = src
		@dst = dst
		@length = length
	end
end

# This class represent a Graph
#  -- It is an array of nodes
#  -- It has an array of edges
class Graph < Array
	attr_reader :edges
	
	def initialize
		@edges = []
	end

	# This methods connect two edges
	def connect(src, dst, length = 1)
		self.push( src ) unless self.include?( src )
		self.push( dst ) unless self.include?( dst )
		@edges.push Edge.new(src, dst, length)
	end

	# This is an auxiliar method for dijkstra algorithm, computing neighbors of a node
	def neighbors(vertex)
		neighbors = []
		@edges.each do |edge|
			neighbors.push edge.dst if edge.src == vertex
		end
		return neighbors.uniq
	end

	# This is an auxiliar method for dijkstra algorithm, computing direct length between two nodes
	def length_between(src, dst)
		@edges.each do |edge|
			return edge.length if edge.src == src and edge.dst == dst
		end
		nil
	end

	# This is dijkstra algorithm, computing minimum distance between two nodes
	def dijkstra(src, dst = nil)
		distances = {}
		previouses = {}
		self.each do |vertex|
			distances[vertex] = nil # Infinity
			previouses[vertex] = nil
		end
		distances[ src ] = 0
		vertices = self.clone
		until vertices.empty?
			nearest_vertex = vertices.inject do |a, b|
				next b unless distances[a]
				next a unless distances[b]
				next a if distances[a] < distances[b]
				b
			end
			break unless distances[nearest_vertex] # Infinity
			if dst and nearest_vertex == dst
				return distances[dst]
			end
			neighbors = vertices.neighbors(nearest_vertex)
			neighbors.each do |vertex|
				alt = distances[nearest_vertex] + vertices.length_between(nearest_vertex, vertex)
				if distances[vertex].nil? or alt < distances[vertex]
					distances[vertex] = alt
					previouses[vertices] = nearest_vertex
					# decrease-key v in Q # ???
				end
			end
			vertices.delete nearest_vertex
		end
		if dst
			return nil
		else
			return distances
		end
	end
end

# Constants defining legend for map

ICE        = '·'
OBSTACLE   = '#'
START      = 'X'
EXIT       = 'O'

# Variations in X and in Y, to iterate them, and compute the four directions in only one block
# EAST, SOUTH, WEST, NORTH

VARIATIONS = [ [1,0], [0,1], [-1,0], [0,-1] ]

# This class represent every input case
# Every Cave is a graph (being the nodes the stop-points, and the edges the paths sliding over the ice)

class Cave < Graph

	# This method reads a cave from input
	def initialize
		super

		# First line contains W,H, Speed and Delay
		@w,@h,@speed,@delay = gets.chomp.split(' ').map( &:to_f )

		# map stores a bi-dimensional array containing the cells
		@map = @h.to_i.times.map do
			gets.chomp.split('')
		end

		# Search for START and EXIT
		@map.each_with_index do |row,y|
			row.each_with_index do |cell,x|
				@start = [x,y] if cell == START
				@exit  = [x,y] if cell == EXIT
			end
		end

		# Add stop-points, from start
		add_edges_from( @start )
	end

	# This method add a node to the graph, and search for sliding alternatives,
	#  adding subsequent nodes recursively
	def add_edges_from( start )

		# If the node already exists, stop
		unless self.include?( start )

			# coordinates of start
			x,y = start

			# add the node to the graph
			push start

			# for each direction
			VARIATIONS.each do |v|

				# coordinates of the variation
				vx,vy = v

				# coordinates of the slide movement
				tx,ty = x,y

				# length of the movement
				len = 0

				# until we found a OBSTACLE or go out the matrix
				while ( [ ICE, EXIT, START ].include?( @map[ ty + vy ][ tx + vx ] ) ) do

					# move the body
					tx += vx
					ty += vy

					# inc the length
					len += 1
				end

				# if we are in another position
				if( len != 0 )

					# invoke recursively
					add_edges_from  [tx,ty]

					# connect the start point with the stop-point found
					# we store the node weight as the time: e/v + t0
					connect( start, [tx,ty], len/@speed + @delay )
				end
			end
		end
	end

	# Problem asks us for the minimum time needed to go out the cave!
	def distance
		dijkstra( @start, @exit )
	end
	
end

# The first line is the number of cases
t = gets.chomp.to_i

# every case
t.times do
	
	# we build a cave and outputs the result (rounded, as problem states)
	puts Cave.new.distance.round
end


