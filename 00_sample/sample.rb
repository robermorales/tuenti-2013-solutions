#!/usr/bin/env ruby

readlines.each do |line|
	     puts line
	              .chomp
	                    .split
	                          .collect( &:to_i )
	                                            .reduce( &:+ )
	# 1. ^ write the result computed this way:
	# 2.      ^ for every line
	# 3.           ^ remove carriage return
	# 4.                 ^ divide by spaces
	# 5.                       ^ cast everything to an int
	# 6.                                         ^ sum everything
end

