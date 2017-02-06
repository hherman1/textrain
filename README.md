# textrain
### Hunter Herman & Ali Mahad

The code is very straightforward. We have classes to manage image processing and global state as well as separate classes for falling characters, managing the characters, and generating them. 

## Character generation

There is a maximum capacity of `1000` characters. Every frame characters are added until they excede capacity. When characters
are generated they are added to a region with twice the height of the window above the window to give the appearance of continuous rain.
There is an 80% chance of adding a random character, and a 20% chance of adding a word from the corpus specified within `text.txt`.

Random characters alter their `speed`, `color`, and `lifetime`s by some ammount capped by a fixed variance for each of those values. 
On the other hand words share across all their component characters a base `x`, `y`, `color`, `speed`, and `lifetime`. Each character of 
a word shifts its own `y` value away from the words base `y` value by a value capped by a fixed variance. 
