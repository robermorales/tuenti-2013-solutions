#!/usr/bin/env ruby

# Graph algorithms are already safely codified on libraries
# `sudo gem install rgl` installs rgl, the best graph lib on ruby

# We only need requiring topsort algorithm and adjacency structs
require 'rgl/topsort'
require 'rgl/adjacency'

# This class represents one script,
#  being @g the graph of scenes,
#  the method initialize builds the graph,
#  the method solve puts the solution
class Script

	def initialize( line )

		# We start with an empty graph
		@g = RGL::DirectedAdjacencyGraph.new

		# We process the line with 3 nested splits
		# Firstly, we will process the chronological scenes, adding the edges
		# Later, we will search for the flashbacks adding corresponding edges
		# Finally, we will add edges for flashforwards
		# 
		# Starting with a line like this
		#  '.a<b>c.d<a<b<c<e.g>f<a'
		# The array scenes will be ==> (Note that the first [] will be ignored using reduce)
		#  [[], [["a"], ["b", "c"]], [["d"], ["a"], ["b"], ["c"], ["e"]], [["g", "f"], ["a"]]]
		#       ___________________  ___________________________________  ____________________
		#          ^                    ^                                    ^
		#          |                    |                                    |
		#          +--------------------+------------------------------------+--------------- Chronological (first of the first array of each scene)
		#               ___________          _____  _____  _____  _____                _____
		#                 ^                    ^      ^      ^      ^                    ^
		#                 |                    |      |      |      |                    |
		#                 +--------------------+------+------+------+--------------------+--- Flashbacks (first of the second and further arrays of each scene)
		#                    _____                                              _____
		#                      ^                                                  ^
		#                      |                                                  |
		#                      +--------------------------------------------------+---------- Flashforwards (non-first of the arrays of each scenes)
		#
		scenes = line.split('.').map do |chronological_scene,i|
			chronological_scene.split('<').map do |flashback|
				flashback.split('>').map do |flashforward|
					flashforward
				end
			end
		end
		scenes.reduce do |prev,scene|
			@g.add_edge( prev.first.first, scene.first.first ) if prev != []
			scene.reduce do |_,flashback|
				@g.add_edge( flashback.first, scene.first.first )
			end
			scene.each do |flashforward_container|
				flashforward_container.reduce do |_,flashforward|
					@g.add_edge( scene.first.first, flashforward )
				end
			end
			scene
		end
	end

	def solve

		# Directed Acyclic Graphs are common representation of lots of problems
		# Temporal order between elements (as in the problem) is one of the most common
		# Extract an ordering that does not violate the restrictions of order is called
		#  topological ordering

		# Different outputs are required if there is only one possible topological ordering
		# From wikipedia [http://en.wikipedia.org/wiki/Directed_acyclic_graph]
		# "a DAG has a unique topological ordering if and only if it has a directed path
		#  containing all the vertices, in which case the ordering is the same as the order
		#  in which the vertices appear in the path."

		# Firstly, we test if the built graph is directed and acyclic
		if ( not @g.directed? ) or ( not @g.acyclic? )
			puts 'invalid'
		else
			# We get one topological ordering
			topological = @g.topsort_iterator.to_a

			# If the order is empty, is impossible to get one
			if topological === []
				puts 'invalid'
			else
				# We get a directed path to test
				bfs = @g.bfs_iterator( topological.first ).to_a

				# If it is the same than the topological path
				#  and in the same order
				if bfs === topological

					# In case of unique alternative, we print it
					puts topological.join(',')
				else

					# In case of many alternatives, we print 'valid'
					puts 'valid'
				end
			end
		end
	end
end

# First line is the number of scripts
n = gets.chomp.to_i

n.times do
	# read the line, build a script with it, and solve the script
	Script.new( gets.chomp ).solve
end
