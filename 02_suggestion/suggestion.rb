#!/usr/bin/env ruby

# We will modify String prototype to create two useful methods
class String

	# This method generates a canonical form of a string
	#  in the way "asdf".canonical => "4adfs"
	# First, the size of the string (to fast reject different size words)
	# Second, the sorted characters.
	# The objective is that two words that can be suggestions of each other
	#  have the same canonical form
	# This method will be used to generate a complementary index,
	#  wich is only ~3% bigger than original dictionary.	
	def canonical
		[ self.size, self.chomp.split('').sort ].join
	end

	# This method generates an index file name from a dictionary file
	def index
		"#{self}.index"
	end

end

# This function ensures that an index file exists for a dictionary,
#  otherwise it creates one file and populates it with a canonical version
#  of each dictionary word.
# Index is only about ~3% bigger than dictionary.
# Creation is fast (about 5min for a 3M-word dictionary)
def create_index( dictionary )

	# test the existence of the index, and exit
	File.stat( dictionary.index )

	# unless there is an error, so
	rescue

	# 1 - it creates the index
	File.open( dictionary.index, "a" ) do |index_file|
		# 2 - it opens the dictionary
		File.open( dictionary ) do |dictionary_file|
			# 3 - for each word of the dictionary
			dictionary_file.readlines.each do |dictionary_line|
				# 4 - puts in the index the canonical form
				index_file.puts dictionary_line.chomp.canonical
			end
		end
	end
end

# "The input consists of comments (lines starting with '#')"
# This method is for ignore the lines starting with #
def ignore_comment
	raise 'Expected #' if gets[ 0 ] != '#'
end

# Name of the dictionary
ignore_comment
dictionary = gets.chomp
create_index( dictionary )

# Number of word that needs suggestions
ignore_comment
n = gets.chomp.to_i

# We process the list of words
ignore_comment
n.times do

	# For each of the words
	word = gets.chomp

	# We search the line numbers of the index where we can find the canonical version
	# `grep` is really fast doing that
	#  -x test for entire lines (faster)
	#  -n outputs also the line number (convenient)
	# `cut` helps us splitting the line "1234:coindicende" (we need the line number only)
	numbers = `grep -xn #{word.canonical} #{dictionary.index} | cut -f1 -d:`.split("\n")

	# We extract the words from the dictionary, knowing the line numbers
	# `sed` is really fast with the expression 'p' (print)
	sed_expr = numbers.map{ |n| "#{n}p;" }.join

	# We invoke sed with the expresion in the form '12p;23;343p;'
	suggestions = `sed -n '#{sed_expr}' #{dictionary}`.split("\n")

	# We do not need suggest the same word, we can delete from list
	suggestions.delete( word )

	# Output in the expected way
	puts "#{ word } -> #{ suggestions.join(' ') }"

end
