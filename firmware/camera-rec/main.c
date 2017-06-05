#include "soc-hw.h"
#define MAX 100*100	
	
uint8_t mod(uint32_t a, uint32_t b){

	return (a-((a/b)*b));
}

int main(){
	/*uint32_t  j=0;
	uart_putchar(1);
	*/
	uint32_t contad=0;
	char Y=0;
	char U=0;
	char V=0;
		
	/*
	for(j=1;j<MAX;j++)
		uart_putchar(j);

	
	uint32_t  j=MAX;
	for(j;j>1;j--)
		uart_putchar(j);
	*/
	camera_takeP();
	pantalla_wEnable(1);
		
	uint32_t i=0;
	while(i<MAX){
		if(mod(i,3)==0){
			Y=camera_pixel(i);
			pantalla_receiveRed(Y);
		}else if(mod(i,3)==1){
			U=camera_pixel(i);
			pantalla_receiveGreen(U);
		}else{
			V=camera_pixel(i);
			pantalla_receiveBlue(V);
			
			Y=0;
			U=0;
			V=0;
			
		}
		i++;
	}

	pantalla_wEnable(0);
	pantalla_reset();
	pantalla_rEnable(1);


	return 0;
	
}

