# Sudoku

## About

Assembly project written for my 4th Semester of my Computer Science Bachelors degree

- [TASM user Guide](http://bitsavers.informatik.uni-stuttgart.de/pdf/borland/turbo_assembler/Turbo_Assembler_Version_5_Users_Guide.pdf)
- [Video Modes](http://www.columbia.edu/~em36/wpdos/videomodes.txt)
- [Interrupts](http://www.ctyme.com/intr/rb-0087.htm)
- [Clear Screen](https://stackoverflow.com/questions/41317491/what-is-the-best-way-to-clear-the-screen-in-32-bit-x86-assembly-language-video)

| [Interrupt](https://github.com/dosasm/masm-tasm/wiki/Interrupt-list-en)         | Topic    |
|---------------------------------------------------------------------------------|----------|
| [`int 10h`](https://en.wikipedia.org/wiki/INT_10H)                              | Video    |
| [`int 16h`](https://en.wikipedia.org/wiki/INT_16H)                              | Keyboard |
| [`int 21h`](https://www.i8086.de/dos-int-21h/dos-int-21h.html)                  | etc.     |
| [`int 33h`](https://github.com/dosasm/masm-tasm/wiki/Interrupt-list-en#int-33h) | Mouse    |

## Setup

- requires DOSBox
- requires TASM binaries

### Compilation

To compile the program, simple run `compile` in the project root.

The steps taken for compiling can be seen within the `compile.bat` file.

### Running the software

To run the software simply type `run` in the project root after compilation.

## How to play

- <https://en.wikipedia.org/wiki/Sudoku>
