#include "soc-hw.h"

int main(){

	uint32_t contad=0;
	char Y=0;
	char U=0;
	char V=0;
	uint32_t matrix[640*480];

	camera_takeP();
	char j=0;
	while(j<99999999){
		uart_putchar(j);
		j++;
	}
	pantalla_wEnable(1);	
	uint32_t i=0;
	while(i<307200){
		if(i%3==0){
			Y=camera_pixel(i);
		}else if(i%3==1){
			U=camera_pixel(i);
		}else{
			V=camera_pixel(i);
			matrix[contad]=Y;
			matrix[contad+1]=U;
			matrix[contad+2]=V;
			Y=0;
			U=0;
			V=0;
			contad=contad+3;
		}
		i++;
	}
	i=0;
	while(i<307200){
		if(i%3==0){
			pantalla_receiveRed(matrix[i]);
		}else if(i%3==1){
			pantalla_receiveGreen(matrix[i]);
		}else{
			pantalla_receiveBlue(matrix[i]);
		}
		i++;
	}

	pantalla_wEnable(0);

	

	return 0;
	
}

