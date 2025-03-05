#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main() {
    if (getuid() != 0) {
        printf("You should run this program in sudo mode.");
        return -1;
    }
    
    char* script = "bash ../configs_mng.sh";
    int exit;
    while (1) {
        if (scanf("%d", &exit) == 1 && exit == -1) break;
        
        //while (getchar() != '\n');
        
        char cmd_buffer[256];
        int i = 0;
        while (script[i] != '\0' && i != 255) {
            cmd_buffer[i] = script[i];
            ++i;
        }
        
        if (i < 255) {
            cmd_buffer[i] = ' ';
            ++i;
        }
        
        char ch;
        while ((ch = getchar()) && ch != '\n' && i != 255) {
            cmd_buffer[i] = ch;
            ++i;
        }
        cmd_buffer[i] = '\0';
        
        printf("\ncommand: '%s'\n", cmd_buffer);
        system(cmd_buffer);
    }
    
    return 0;
}
