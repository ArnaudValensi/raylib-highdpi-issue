#include "utils.h"
#include <stdio.h>
#include <stdlib.h>

void check_handler(char *condition, char *function, char *file, int line) {
    printf("check failed: ( %s ), function %s, file %s, line %d\n", condition, function, file, line);
    exit(1);
}
