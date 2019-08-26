#include "stdio.h"
#include "bsp/syscall.h"

void wait() {
    int32_t x = 0;
    for(uint32_t i=0; i<64000; i++) {
        x++;
        if(x == 6000) {
            return;
       }
    }
}

int main() {
    reg_uart_clkdiv = 104; // 115200 baud
    while(1) {
        wait();
        printf("Hello Word\n");
    }
    return 0;
}