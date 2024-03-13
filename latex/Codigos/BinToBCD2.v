//Conversor de Binario para BCD (Display de 7 segmentos)
module BinToBCD2(binario, dezena, unidade);
	input [6:0] binario;
	output reg [3:0] dezena, unidade;
	reg [3:0] centena;
	integer i;
	
	always@(binario) begin
		centena = 4'D0;
		dezena = 4'D0;
		unidade = 4'D0;

		for(i = 6; i>=0; i=i-1) begin
			if(centena >= 5)
				centena = centena + 3;
			if (dezena >= 5)
				dezena = dezena + 3;
			if (unidade >= 5)
				unidade = unidade + 3;
				
			centena = centena << 1;
			centena[0] = dezena[3];
			
			dezena = dezena << 1;
			dezena[0] = unidade[3];
			
			unidade = unidade << 1;
			unidade[0] = binario[i];
		end	
	end	
endmodule
