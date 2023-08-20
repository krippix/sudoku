# This small tool is supposed to generate a sudoku array to use in the asm source code
# For example to replace easy_sudoku

# Once startet, this tool will ask for the numbers you want row by row, 0 represents empty
# seperation happens by pressing space bar

def main():
    print("Welcome to my weird asm-sudoku-generator thingy!")

    print("Please Enter 9 digits, separated by spacebars")

    result_list = []

    i = 0
    while i < 9:
        print(f"row {i+1}: ", end="")
        tmp = input()
        result_split = tmp.split(" ")
        result_list.append(result_split)

    # convert result to integers
    #final_list = []
    #for num in result_list:
    #    final_list.append(chr(num))

    # check if list has correct size
    if len(result_list) != 81:
        print(f"Incorrect list length: {len(result_list)}!")
        exit()
    
    result_string = ""
    for num in result_list:
        result_string += hex(ord(num)).upper()[2:]+"h"

    print(result_string)

if __name__ == "__main__":
    main()