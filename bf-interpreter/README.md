# Brainfuck Interpreter 


## Explanation 

> Some of the notes i writed/found them while i was learning brainfuck 

###### MODEL:

The brainfuck language usesasimple machine model consisting of the program and
instruction pointer, as well as an array of at least 30000 byte cells initialized
to zero, amovable data pointer (initialized to point to the leftmost byte of the array);
and two streams of bytes for input and output (most often connected toakeyboard and
amonitor respectively, and using the ASCII character encoding).

###### DESIGN:

The language consists of eight commands, listed below. A brainfuck program is
asequence of these commands, possibly interspersed with other characters
(which are ignored). The commands are executed sequentially, with some exceptions:
an instruction pointer begins at the first command, and each command it points to is
executed, after which it normally moves forward to the next command. The program
terminates when the instruction pointer moves past the last command.

###### COMMANDS:

- `>`   increment the data pointer(to point to the next cell to the right).
- `<`   decrement the data pointer(to point to the next cell to the left).
- `+`   increment (increase by one)the byte at the data pointer.
- `-`   decrement (decrease by one)the byte at the data pointer.
- `.`   output the byte at the data pointer.
- `,`   accept one byte of input, storing its value in the byte at the data pointer.
- `[`   if the byte at the data pointer is zero, then instead of moving the instruction pointer forward to the next command, jump it forward to the command after the matching `]` command.
- `]`   if the byte at the data pointer is nonzero, then instead of moving the instruction pointer forward to the next command, jump it back to the command after the matching `[` command.

## Examples

- `VISUAL MEMORY REPRESENTATION:`

###### Initial environment:
```
cell#               0   1   2   3   4   5   6   7   8   9                                         30000

 data             |_0_|___|___|___|___|___|___|___|_0_|_0_|_0_|_0_|_0_|_0_|.......................|_0_|
pointer             ^
```
> array of at least 30,000 byte cells initialized to zero

###### After Code Execution:

1. `>>>>`
```
cell#               0   1   2   3   4   5   6   7   8   9                                         30000

 data             |_0_|_0_|_0_|_0_|_0_|_0_|_0_|_0_|_0_|_0_|_0_|_0_|_0_|_0_|.......................|_0_|
pointer                             ^
```
> move the pointer to the right 4 times 


2. `+++++>++`
```
cell#               0   1   2   3   4   5   6   7   8   9                                         30000

 data             |_0_|_0_|_0_|_5_|_2_|_0_|_0_|_0_|_0_|_0_|_0_|_0_|_0_|_0_|.......................|_0_|
pointer                             ^
```
> increment the actual cell (5 times) and move to right and increment it (2 times) 


3. `[>+>+<<-]`
```
cell#               0   1   2   3   4   5   6   7   8   9                                         30000

 data             |_0_|_0_|_0_|_5_|_0_|_2_|_2_|_0_|_0_|_0_|_0_|_0_|_0_|_0_|.......................|_0_|
pointer                             ^
```
>  initialize a loop the value of the current cell is equal to 0 (current value is 2 "index #4") inside the loop move to right and increment move to right increment move to the left cell 2 times and decrement our condition cell 

## How to install

```
git clone https://github.com/UncleJ4ck/bf-inter
cd bf-inter
Make
./bf filename
```


## TO-DO

- [ ] Optimizing the code 
- [ ] Fixing Bugs
- [ ] Adding the DEBUG option
