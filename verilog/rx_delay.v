module rx_delay(
                input      clk,
                input      in,
                output reg maj
                );

   reg [4:0]               rx_dly;
   
   always @(posedge clk)
     begin
        maj <= (rx_dly[0] + rx_dly[1] + rx_dly[2] + rx_dly[3] + rx_dly[4]) > 2;
        rx_dly <= {rx_dly[4:0],in};     
     end // else: !if(!rstn)
   
endmodule // rx_delay
