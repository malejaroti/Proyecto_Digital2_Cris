`timescale 1ns / 1ps
// Divisor de reloj para la nexys4, para converitir el reloj de i2c 
// a un rango permitido por el periférico
//
//////////////////////////////////////////////////////////////////////////////////
module divisor_frecuencia(
    	input clk,
	input divisor, 
    	output mclk
);
	 
reg [2:0] contador= 0;
reg mclko=0;
assign mclk = mclko;

always @(posedge clk) begin
    contador = contador + 1;
      if(contador == divisor) begin
        mclko = ~mclko; //genera la señal de reloj
        contador = 0; 	//reset del contador
      end
end

endmodule 
