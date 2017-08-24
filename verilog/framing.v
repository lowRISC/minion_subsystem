/*
This file is part of the ethernet_mac project. https://github.com/pkerling/ethernet_mac
MAC sublayer functionality (en-/decapsulation, FCS, IPG)
 
Copyright (c) 2015, Philipp Kerling
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of ethernet_mac nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

* Neither the source code, nor any derivative product, may be used to operate
  weapons, nuclear facilities, life support or other mission critical
  applications where human life or property may be at stake or endangered.
  
* Neither the source code, nor any derivative product, may be used for military
  purposes.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

This Verilog version generated using 
vhdl2verilog -in ../ethernet_mac/framing.vhd -out framing.v -top framing -arch rtl

vhdl2verilog is available from: http://www.edautils.com/vhdl2verilog.html
 
Corrections to pass formality verification by Jonathan Kimmitt, to whom all enquiries should be directed
 */

`default_nettype none

module framing(
        tx_reset_i,
        tx_clock_i,
        rx_reset_i,
        rx_clock_i,
        mac_address_i,
        tx_enable_i,
        tx_data_i,
        tx_byte_sent_o,
	tx_fcs_o,
        tx_busy_o,
        rx_frame_o,
        rx_data_o,
        rx_byte_received_o,
        rx_error_o,
        rx_frame_size_o,
        rx_packet_length_o,
	rx_fcs_o,
	rx_fcs_err_o,
        mii_tx_enable_o,
        mii_tx_data_o,
        mii_tx_byte_sent_i,
        mii_tx_gap_o,
        mii_rx_frame_i,
        mii_rx_data_i,
        mii_rx_byte_received_i,
        mii_rx_error_i
    );
    input wire tx_reset_i;
    input wire tx_clock_i;
    input wire rx_reset_i;
    input wire rx_clock_i;
    input wire [47:0]mac_address_i;
    input wire tx_enable_i;
    input wire [7:0]tx_data_i;
    output tx_byte_sent_o;
    output tx_busy_o;
    output rx_frame_o;
    output [7:0]rx_data_o;
    output rx_byte_received_o;
    output rx_error_o;
    output wire [10:0]rx_frame_size_o;
    output mii_tx_enable_o;
    output [7:0]mii_tx_data_o;
    input wire mii_tx_byte_sent_i;
    output mii_tx_gap_o;
    input wire mii_rx_frame_i;
    input wire [7:0]mii_rx_data_i;
    input wire mii_rx_byte_received_i;
    input wire mii_rx_error_i;
    output reg [31:0]rx_fcs_o;
    output reg [31:0]tx_fcs_o;
    output wire rx_fcs_err_o;
    output reg [10:0]rx_packet_length_o;
   
   localparam CRC32_POSTINVERT_MAGIC = 32'HC704DD7B;
   
    function [7:0] extract_byte;
       input [47:0] vec;
       input [2:0]  byteno;
       begin
	  extract_byte = vec >> {byteno,3'b000};
       end
    endfunction 

    function [7:0] fcs_output_byte;
       input [31:0] fcs;
       input [31:0] byteno;
       reg [31:0] reversed;
       integer 	  i;
       
       begin
	  for (i = 0; i < 32; i=i+1)
	    reversed[31-i] = fcs[i];
	  fcs_output_byte = ~(reversed >> {byteno,3'b000});
       end
    endfunction 

    function [31:0] update_crc32;
        input [31:0] old_crc;
        input [7:0] input0;
        reg [7:0] data_out;
        reg 	 feedback;
        reg [31:0] poly, new_crc;
       
        integer 	 i;
       
        begin
	  poly = (1<<26)|(1<<23)|(1<<22)|(1<<16)|
		   (1<<12)|(1<<11)|(1<<10)|(1<<8)|(1<<7)|(1<<5)|(1<<4)|(1<<2)|(1<<1)|(1<<0);
	  new_crc = old_crc;
	  for (i = 0; i < 8; i=i+1)
	    begin
	       feedback = new_crc[31] ^ input0[i];
	       new_crc = feedback ? {new_crc[30:0],1'b0} ^ poly : {new_crc[30:0],1'b0};
	    end
	   update_crc32 = new_crc;
	end
       
    endfunction 

    reg tx_byte_sent_o;
    reg [3:0]tx_state;
    reg mii_tx_enable_o;
    reg tx_busy_o;
    reg [7:0]mii_tx_data_o;
    reg mii_tx_gap_o;
    reg [6:0]tx_padding_required;
    reg [31:0]tx_frame_check_sequence;
    reg [2:0]tx_mac_address_byte;
    reg [3:0]tx_interpacket_gap_counter;
    reg [2:0]rx_state;
    reg [2:0]rx_padding;
    reg rx_error_o;
    reg [7:0]rx_data_o;
    reg rx_byte_received_o;
    reg rx_frame_o;
    reg [2:0]rx_mac_address_byte;
    reg rx_is_group_address;
    reg [10:0]rx_frame_size;
    reg [31:0]rx_frame_check_sequence;
    reg [1:0]  update_fcs;
    reg [7:0]  data_out;
    wire rx_fcs_err;

    assign rx_frame_size_o = rx_frame_size;
    assign rx_fcs_err_o = rx_fcs_err;
    assign rx_fcs_err = rx_frame_check_sequence != CRC32_POSTINVERT_MAGIC;
   
    always @ (  tx_state or  mii_tx_byte_sent_i)
    begin
        if ( ( ( ( tx_state == 'b1010 ) | ( tx_state == 'b1000 ) ) | ( tx_state == 'b1001 ) ) & ( mii_tx_byte_sent_i == 1'b1 ) ) 
        begin
            tx_byte_sent_o <= 1'b1;
        end
        else
        begin 
            begin
                tx_byte_sent_o <= 1'b0;
            end
        end
    end
    always @ ( posedge tx_clock_i)
        if ( tx_reset_i ) 
        begin
            tx_state <= 'b0;
            mii_tx_enable_o <= 1'b0;
            tx_busy_o <= 1'b1;
            tx_padding_required <= 0;
            tx_fcs_o <= 32'b0;
            mii_tx_data_o <= 8'b0;
        end
        else
        begin 
            begin
                mii_tx_enable_o <= 1'b0;
                tx_busy_o <= 1'b0;
                if ( tx_state == 'b0 ) 
                begin
                    if ( tx_enable_i == 1'b1 ) 
                    begin
                        tx_state <= 1'b1;
                        mii_tx_data_o <= 8'b01010101;
                        mii_tx_enable_o <= 1'b1;
                        mii_tx_gap_o <= 1'b0;
                        tx_busy_o <= 1'b1;
                    end
                end
                else
                begin 
                    mii_tx_enable_o <= 1'b1;
                    tx_busy_o <= 1'b1;
                    if ( mii_tx_byte_sent_i == 1'b1 ) 
                    begin
                        mii_tx_gap_o <= 1'b0;
                        data_out = 8'b0;
                        update_fcs = 'b0;
                        case ( tx_state ) 
                        'b0:
                        begin
                        end
                        'b1, 
                        'b10, 
                        'b11, 
                        'b100, 
                        'b101:
                        begin
                            tx_state <= tx_state + 3'b001;
                            data_out = 8'b01010101;
                        end
                        'b110:
                        begin
                            tx_state <= 3'b111;
                            data_out = 8'b01010101;
                        end
                        'b111:
                        begin
                           tx_state <= 'b1010; // was 'b1000;
                            data_out = 8'b11010101;
                            tx_padding_required <= ( 46 + 2 + 6 + 6 );
                            tx_frame_check_sequence <= { 32{1'b1} };
                            tx_mac_address_byte <= 3'b000;
                        end
                        'b1000:
                        begin
                            data_out = tx_data_i;
                            update_fcs = 1'b1;
                            if ( tx_mac_address_byte < 3'b110 ) 
                            begin
                                tx_mac_address_byte <= ( tx_mac_address_byte + 3'b001 );
                            end
                            else
                            begin 
                                if ( tx_data_i == 8'b11111111 ) 
                                begin
                                    tx_state <= 'b1001;
                                    data_out = mac_address_i[7:0];
                                    tx_mac_address_byte <= 3'b001;
                                end
                                else
                                begin 
                                    tx_state <= 'b1010;
                                end
                            end
                            if ( tx_enable_i == 1'b0 ) 
                            begin
                                tx_state <= 'b1011;
                                data_out = 8'b00000000;
                            end
                        end
                        'b1001:
                        begin
                            data_out = extract_byte(mac_address_i,tx_mac_address_byte);
                            update_fcs = 1'b1;
                            if ( tx_mac_address_byte < ( 3'b110 - 3'b001 ) ) 
                            begin
                                tx_mac_address_byte <= ( tx_mac_address_byte + 3'b001 );
                            end
                            else
                            begin 
                                tx_state <= 'b1010;
                            end
                        end
                        'b1010:
                        begin
                            data_out = tx_data_i;
                            update_fcs = 1'b1;
                            if ( tx_enable_i == 1'b0 ) 
                            begin
                                if ( tx_padding_required == 0 ) 
                                begin
                                    tx_state <= 'b1100;
                                    data_out = fcs_output_byte(tx_frame_check_sequence,0);
                                    update_fcs = 'b0;
                                end
                                else
                                begin 
                                    tx_state <= 'b1011;
                                    data_out = 8'b00000000;
                                end
                            end
                        end
                        'b1011:
                        begin
                            data_out = 8'b00000000;
                            update_fcs = 1'b1;
                            if ( tx_padding_required == 0 ) 
                            begin
                                tx_state <= 'b1100;
                                data_out = fcs_output_byte(tx_frame_check_sequence,0);
                                update_fcs = 'b0;
                            end
                        end
                        'b1100:
                        begin
                            tx_state <= tx_state + 3'b001;
                            data_out = fcs_output_byte(tx_frame_check_sequence,1);
                        end
                        'b1101:
                        begin
                            tx_state <= tx_state + 3'b001;
                            data_out = fcs_output_byte(tx_frame_check_sequence,2);
                        end
                        'b1110:
                        begin
                            tx_state <= 4'b1111;
                            data_out = fcs_output_byte(tx_frame_check_sequence,3);
                            tx_interpacket_gap_counter <= 0;
                        end
                        'b1111:
                        begin
                            mii_tx_gap_o <= 1'b1;
                            if ( tx_interpacket_gap_counter == ( 12 - 1 ) ) 
                            begin
			       tx_fcs_o <= tx_frame_check_sequence;
                               tx_state <= 'b0;
                            end
                            else
                            begin 
                                tx_interpacket_gap_counter <= ( tx_interpacket_gap_counter + 1 );
                            end
                        end
                        endcase
                        mii_tx_data_o <= data_out;
                        if ( update_fcs ) 
                        begin
                            tx_frame_check_sequence <= update_crc32(tx_frame_check_sequence,data_out);
                        end
                        if ( ( ( ( tx_state == 'b1000 ) | ( tx_state == 'b1001 ) ) | ( tx_state == 'b1010 ) ) | ( tx_state == 'b1011 ) ) 
                        begin
                            if ( tx_padding_required > 0 ) 
                            begin
                                tx_padding_required <= ( tx_padding_required - 1 );
                            end
                        end
                    end
                end
            end
        end

    always @ ( posedge rx_clock_i)
        if ( rx_reset_i ) 
        begin
           rx_state <= 'b0;
           rx_fcs_o <= 32'b0;
        end
        else
        begin 
            begin
                rx_error_o <= 1'b0;
                rx_data_o <= mii_rx_data_i;
                rx_byte_received_o <= 1'b0;
                rx_frame_o <= 1'b0;
                case ( rx_state ) 
                'b0:
                begin
                    rx_mac_address_byte <= 3'b000;
                    rx_is_group_address <= 1'b1;
                    rx_frame_check_sequence <= { 32{1'b1} };
                    if ( mii_rx_frame_i == 1'b1 ) 
                    begin
                       rx_frame_size <= 0;
		       rx_packet_length_o <= 0;
                       if ( mii_rx_byte_received_i == 1'b1 ) 
                         begin
                            case ( mii_rx_data_i ) 
                            8'b11010101:
                            begin
                                rx_state <= 'b1;
                            end
                            8'b01010101:
                            begin
                            end
                            default :
                            begin
                                rx_state <= 'b11;
                            end
                            endcase
                         end
                       if ( mii_rx_error_i == 1'b1 ) 
                         begin
                            rx_state <= 'b11;
                         end
                    end
                end
                'b1:
                begin
                    rx_frame_o <= 1'b1;
                    rx_byte_received_o <= mii_rx_byte_received_i;
                    if ( mii_rx_frame_i == 1'b0 ) 
                    begin
                        rx_state <= 'b100;
                        rx_padding <= 'b100;
		        rx_fcs_o <= rx_frame_check_sequence;
		        if ( rx_fcs_err == 0)
			  rx_packet_length_o <= rx_frame_size;
                        if ( ( ( ( mii_rx_error_i == 1'b1 ) | rx_fcs_err ) | ( rx_frame_size < ( ( 46 + 2 + 6 + 6 ) + ( 32 / 8 ) ) ) ) | ( rx_frame_size > ( ( 1500 + 2 + 6 + 6 ) + ( 32 / 8 ) ) ) )
                        begin
                            rx_error_o <= 1'b1;
                        end
                    end
                    else
                    begin 
                        if ( mii_rx_byte_received_i == 1'b1 ) 
                        begin
                            rx_frame_check_sequence <= update_crc32(rx_frame_check_sequence,mii_rx_data_i);
                            if ( rx_frame_size < 1500 + 2 + 6 + 6 + 4 + 1 ) 
                            begin
                                rx_frame_size <= ( rx_frame_size + 1 );
                            end
                            if ( rx_mac_address_byte < 3'b110 ) 
                            begin
                                if ( rx_mac_address_byte == 3'b000 ) 
                                begin
                                    if ( mii_rx_data_i[0] == 1'b0 ) 
                                    begin
                                        rx_is_group_address <= 1'b0;
                                        if ( mii_rx_data_i != extract_byte(mac_address_i,rx_mac_address_byte) ) 
                                        begin
                                            rx_state <= 'b10;
                                        end
                                    end
                                end
                                else
                                begin 
                                    if ( rx_is_group_address == 1'b0 ) 
                                    begin
                                        if ( mii_rx_data_i != extract_byte(mac_address_i,rx_mac_address_byte) ) 
                                        begin
                                            rx_state <= 'b10;
                                        end
                                    end
                                end
                                rx_mac_address_byte <= ( rx_mac_address_byte + 3'b001 );
                            end
                        end
                        if ( mii_rx_error_i == 1'b1 ) 
                        begin
                            rx_state <= 'b10;
                        end
                    end
                end
                'b11:
                begin
                    if ( mii_rx_frame_i == 1'b0 ) 
                    begin
                        rx_state <= 'b0;
                    end
                end
                'b10:
                begin
                    rx_frame_o <= 1'b1;
                    rx_error_o <= 1'b1;
                    if ( mii_rx_frame_i == 1'b0 ) 
                    begin
                        rx_state <= 'b0;
                    end
                end
                'b100:
                begin
                    rx_frame_o <= 1'b1;
                    rx_byte_received_o <= mii_rx_byte_received_i;
                    if ( rx_padding == 1'b0 ) 
                      begin
                        rx_state <= 'b0;
                      end
		    else if ( mii_rx_byte_received_i == 1'b1 ) 
                      begin
                        rx_padding <= rx_padding - 1;
                        rx_frame_size <= rx_frame_size + 1;
                      end
                end
                endcase
            end
        end

endmodule 
