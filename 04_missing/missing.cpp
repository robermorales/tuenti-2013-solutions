/**
 * This program only generates a list with the 100 numbers missing in integers file
 *
 * For doing that, it reads the file step by step, marking to true a bitset of 2^31 positions
 *
 * Then, it searchs for false bits and cout them.
 *
 * The predicted use is `make missing && ./missing > missing-list.txt`
 *
 * The measured time is under 4 minutes
 *
 */

#include <iostream>
#include <fstream>
#include <bitset>

using namespace std;

/** Size of the bitset 2^31 = 2147483648 */
#define SIZE 2147483648

/** Number of missing integers */
#define MISSING 100

int main()
{
	/** exists is a bitset of SIZE size */
	bitset<SIZE>* exists = new bitset<SIZE>( false );

	/** integers is the binary file we are reading */
	ifstream integers( "integers", ios::binary | ios::in );

	/** this variable is the target of the reading */
	unsigned int number_on_the_list;

	/** for every integer on the file */
	for( long remaining = SIZE - MISSING; remaining > 0 ; remaining -- ) {

		/** we read an integer */
		integers.read( (char*) &number_on_the_list, 4 );

		/** and we mark as existent in the bitset */
		exists->set( number_on_the_list );
	}

	/** then we go throw the bitset */
	for( unsigned int i = 0 ; i < SIZE ; i ++ ){

		/** and output the items that do not exist */
		if( exists->test( i ) == false )
			cout << i << endl;
	}
}



