# This small tool is supposed to generate a sudoku array to use in the asm source code
# For example to replace easy_sudoku

# Once startet, this tool will ask for the numbers you want row by row, 0 represents empty
# seperation happens by pressing space bar

def main():
    print("Welcome to my weird asm-sudoku-generator thingy!")

    print("Please Enter 9 digits and hit enter after each row:")

    result_list = []

    i = 0
    while i < 9:
        tmp = input()
        result_split = tmp.split(" ")
        result_list.extend(result_split)

        i += 1

    # convert results to integers
    int_list = []
    for num in result_list:
        num = int(num)
        if num != 0:
            num = num | 0b0001_0000 # marks as predetermined

        int_list.append(num)

    # check if list has correct size
    if len(result_list) != 81:
        print(f"Incorrect list length: {len(result_list)}!")
        exit()
    
    result_string = ""
    for num in int_list:
        result_string += hex(ord(chr(num))).upper()[2:]+"h, "

    print(result_string[:-2])

if __name__ == "__main__":
    main()