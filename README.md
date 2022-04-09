# Twenty-Eight Totals

This command line tool accompanies my daily numbers game, [Twenty-Eight](http://twenty-eight.robowenking.com/). It brute forces a solution to any given puzzle (where it exists).

Requires `Ruby`. The code was written with `version 2.6.6`. I'm sure it will work with other versions, but I haven't checked.

## Usage

In this folder in the command line, type: `ruby numbers_to_totals.rb <numbers>`. That will output an array of the integers 1..28 which can be made with the given `<numbers>` (used once each) and the operators +, -, \*, /, ! and ^.

Example: `ruby numbers_to_totals.rb 9 9 10 11`

Output: `[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 16, 17, 18, 19, 20, 21, 22, 24, 28]`

Note that while the game uses 4 digits, the tool generates its answers recursively and should work for more numbers, it becomes very slow, very quickly.

The output can be expanded via the use of additional flags:

**--count / -c**

`-c #=> 22 valid solutions`

**--equations / -e**

```
-e #=>
1: ((9/(11-10))/9)
2: (((11!/10)/9!)-9)
3: (((10+11)-9)-9)
...
15 not possible
...
28: (10-(9*(9-11)))
```

**--time / -t**

`-t #=> Time elapsed: 6.344239430000016s`

#### Deprecated version

`possible_totals.rb` is deprecated and not recommended for use, although it should still work in many cases.
