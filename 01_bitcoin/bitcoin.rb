#!/usr/bin/env ruby

class Wallet

	# we store here the amount of EUR and BTC we have
	@eur
	@btc

	def initialize( eur_initial )

		# we initialize the initial amount of EUR
		@eur = eur_initial

		# we start with no BTC
		@btc = 0

	end

	def try_to_sell( rate )
		
		# if there is something to sell
		if @btc > 0

			# we earn euro
			@eur += @btc * rate

			# and we end with no BTC
			@btc   = 0
		end

	end

	def try_to_buy( rate )

		# "can't buy a fraction of a bitcoin", so
		# if we have money for at least one BTC...
		if @eur >= rate

			# we find the maximum BTC we can buy
			maxbtc = ( @eur / rate ).to_i

			# we pay for them
			@eur -= maxbtc * rate

			# and we store it in our wallet
			@btc += maxbtc

		end
	end

	# output: "The maximum amount of euros
	# that you will have at the end
	# in a different line for each test case."
	def show_euro
		puts @eur
	end

end

# First line contains the number of test cases, T
T = gets.chomp.to_i

# and T cases follow
T.times do

	# "Each test case consists of one integer N (1 ≤ N ≤ 100)"
	n = gets.chomp.to_i

	# "indicating your initial budget in euros."
	wallet = Wallet.new( n )

	# we store here the last rate after processing the list
	# in order to sell the last BTC to maximize EUR
	lastrate =

		# "In the next line"
		gets.chomp.

			# "there is a list"
			split.

				# "of integers"
				map( &:to_i ).reduce do | prev, current |

				# "indicating the future value of BTC"
				currentrate = current.to_i

				# if there is already a pair of values
				if prev

					# we try to sell if rate is descending
					if prev > currentrate
						wallet.try_to_sell( prev )

					# and we try to buy if it is ascending
					elsif prev < currentrate
						wallet.try_to_buy ( prev )

					end
				end

				# pass the value to the next iteration
				currentrate
			end

	# Finally we sell all of our BTC, since we must maximize EUR
	wallet.try_to_sell( lastrate )

	# and we show the expected output
	wallet.show_euro

end



