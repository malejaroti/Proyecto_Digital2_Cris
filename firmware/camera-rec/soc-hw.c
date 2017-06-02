#include "soc-hw.h"

uart_t  *uart0  = (uart_t *)   0x20000000;
timer_t *timer0 = (timer_t *)  0x30000000;
pantalla_t  *pantalla0  = (pantalla_t *)   0x40000000;
//uart_t  *uart1  = (uart_t *)   0x20000000;
camera_t   *camera0   = (camera_t *)    0x50000000;
i2c_t   *i2c0   = (i2c_t *)    0x60000000;

isr_ptr_t isr_table[32];

void prueba()
{
	   uart0->rxtx=30;
	   timer0->tcr0 = 0xAA;
	   //gpio0->ctrl=0x55;
	   //i2c0->rxtx=5;
	   //i2c0->divisor=5;

}
void tic_isr();
/***************************************************************************
 * IRQ handling
 */
void isr_null()
{
}

void irq_handler(uint32_t pending)
{
	int i;

	for(i=0; i<32; i++) {
		if (pending & 0x01) (*isr_table[i])();
		pending >>= 1;
	}
}

void isr_init()
{
	int i;
	for(i=0; i<32; i++)
		isr_table[i] = &isr_null;
}

void isr_register(int irq, isr_ptr_t isr)
{
	isr_table[irq] = isr;
}

void isr_unregister(int irq)
{
	isr_table[irq] = &isr_null;
}

/***************************************************************************
 * TIMER Functions
 */
void msleep(uint32_t msec)
{
	uint32_t tcr;

	// Use timer0.1
	timer0->compare1 = (FCPU/1000)*msec;
	timer0->counter1 = 0;
	timer0->tcr1 = TIMER_EN;

	do {
		//halt();
 		tcr = timer0->tcr1;
 	} while ( ! (tcr & TIMER_TRIG) );
}

void nsleep(uint32_t nsec)
{
	uint32_t tcr;

	// Use timer0.1
	timer0->compare1 = (FCPU/1000000)*nsec;
	timer0->counter1 = 0;
	timer0->tcr1 = TIMER_EN;

	do {
		//halt();
 		tcr = timer0->tcr1;
 	} while ( ! (tcr & TIMER_TRIG) );
}


uint32_t tic_msec;

void tic_isr()
{
	tic_msec++;
	timer0->tcr0     = TIMER_EN | TIMER_AR | TIMER_IRQEN;
}

void tic_init()
{
	tic_msec = 0;

	// Setup timer0.0
	timer0->compare0 = (FCPU/10000);
	timer0->counter0 = 0;
	timer0->tcr0     = TIMER_EN | TIMER_AR | TIMER_IRQEN;

	isr_register(1, &tic_isr);
}


/***************************************************************************
 * UART Functions
 */
void uart_init()
{
	//uart0->ier = 0x00;  // Interrupt Enable Register
	//uart0->lcr = 0x03;  // Line Control Register:    8N1
	//uart0->mcr = 0x00;  // Modem Control Register

	// Setup Divisor register (Fclk / Baud)
	//uart0->div = (FCPU/(57600*16));
}

char uart_getchar()
{   
	while (! (uart0->ucr & UART_DR)) ;
	return uart0->rxtx;
}

void uart_putchar(char c)
{
	while (uart0->ucr & UART_BUSY) ;
	uart0->rxtx = c;
}

void uart_putstr(char *str)
{
	char *c = str;
	while(*c) {
		uart_putchar(*c);
		c++;
	}
}

/***************************************************************************
 * Camera Functions
 */

void camera_takeP(){
	camera0->Tomar_imagen=1;
	while(!(camera0->Picture_Avail))
		uart_putchar(camera0->Tomar_imagen1);
}

void camera_sendP(){
	char pixel;
	int i=0;
	while(i<307200) /*for(i=0;i<307200;i++)*/{
		camera0->pIm=i;		//wb_address=camera0->pIm	// wb_dat_i=i 
		pixel=camera0->pIm;	//wb_address=camera0->pIm(i)	// pixel=wb_dat_o
		uart_putchar(pixel);
		
		i++;
	}
}

char camera_pixel(int address){
	char pixel;
	camera0->pIm=address;
	pixel=camera0->pIm;
	return pixel;

}

/***************************************************************************
 * Pantalla Functions
 */

void pantalla_receiveRed(char pixel){
	pantalla0->red=pixel;
}

void pantalla_receiveGreen(char pixel){
	pantalla0->green=pixel;
}

void pantalla_receiveBlue(char pixel){
	pantalla0->blue=pixel;
}

void pantalla_wEnable(int estado){
	pantalla0->w_enable=estado;
}


/***************************************************************************
 * I2C Functions
 */


void i2c_init(uint8_t PRERlo,uint8_t PRERhi){
	i2c0->prerL = PRERlo;
	i2c0->prerH = PRERhi;
	i2c0->ctr   = 0x80;    //Enable core	

}

//The device slave addresses are 42 for write and 43 for read.

void i2c_write(uint8_t addr,uint8_t slvAddr,uint8_t data){ 
	i2c0->txr = addr<<1;
	i2c0->cr   = 0x90;		//Start and write
	/*while(!(i2c0->sr & tip)); //falta definir tip
	i2c0->txr = slvAddr;		
	i2c0->cr   = 0x10;		//Write
	while(!(i2c0->sr & tip)); 
	i2c0->txr = data;
	i2c0->cr   = 0x50;		//Write and stop
	while(!(i2c0->sr & tip));*/
}

void i2c_read(uint8_t addr,uint8_t slvAddr){
	uint8_t data;
	i2c0->txr = (addr<<1)|1;
	i2c0->cr   = 0x90;		//Start and write
	/*while(!(i2c0->sr & tip)); //falta definir tip
	i2c0->txr = slvAddr;		
	i2c0->cr   = 0x10;		//Write
	while(!(i2c0->sr & tip)); 
	data = i2c0->rxr;
	i2c0->cr   = 0x28;		//Read and stop
	while(!(i2c0->sr & tip));
	uart_putchar(data);*/

}


