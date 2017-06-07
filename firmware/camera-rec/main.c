#include "soc-hw.h"
#define MAX 76800
	
int main(){
	while(1){
	uint32_t pixel=0;
	camera_takeP();
	pantalla_wEnable(1);
		
	uint32_t i=0;
	while(i<MAX){
		pixel=camera_pixel(i);
		pantalla_receivePixel(pixel);
		pantalla_receivePixel(pixel);
		i++;
	}

	pantalla_wEnable(0);
	pantalla_reset();
	pantalla_rEnable(1);
	}
	return 0;
}

