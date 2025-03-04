#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main() {
    if (getuid() != 0) {
        printf("You should run this program in sudo mode.");
        return -1;
    }
    
    system("cp /home/dartwint/Documents/TLP/profiles/power_save.conf /etc/tlp.d/power_save.conf");
    
    return 0;
}
