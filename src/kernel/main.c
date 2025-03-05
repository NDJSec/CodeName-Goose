#include "print.h"
#include "user_input.h"

void kernel_main()
{
    print_clear();
    print_set_color(PRINT_COLOR_LIGHT_CYAN, PRINT_COLOR_BLACK);
    print_str("Welcome to Codename-Goose v0.1 \n");

    print_str("New print test");
    
    print_newline();

    test_input();
}
