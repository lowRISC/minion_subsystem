`default_nettype wire

module framing(
        tx_reset_i,
        tx_clock_i,
        rx_reset_i,
        rx_clock_i,
        mac_address_i,
        tx_enable_i,
        tx_data_i,
        tx_byte_sent_o,
        tx_busy_o,
        rx_frame_o,
        rx_data_o,
        rx_byte_received_o,
        rx_error_o,
        rx_frame_size_o,
        mii_tx_enable_o,
        mii_tx_data_o,
        mii_tx_byte_sent_i,
        mii_tx_gap_o,
        mii_rx_frame_i,
        mii_rx_data_i,
        mii_rx_byte_received_i,
        mii_rx_error_i
    );
    input tx_reset_i;
    input tx_clock_i;
    input rx_reset_i;
    input rx_clock_i;
    input [47:0]mac_address_i;
    input tx_enable_i;
    input [7:0]tx_data_i;
    output tx_byte_sent_o;
    output tx_busy_o;
    output rx_frame_o;
    output [7:0]rx_data_o;
    output rx_byte_received_o;
    output rx_error_o;
    output [10:0]rx_frame_size_o;
    output mii_tx_enable_o;
    output [7:0]mii_tx_data_o;
    input mii_tx_byte_sent_i;
    output mii_tx_gap_o;
    input mii_rx_frame_i;
    input [7:0]mii_rx_data_i;
    input mii_rx_byte_received_i;
    input mii_rx_error_i;

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
    reg [1:0]rx_state;
    reg rx_error_o;
    reg [7:0]rx_data_o;
    reg rx_byte_received_o;
    reg rx_frame_o;
    reg [2:0]rx_mac_address_byte;
    reg rx_is_group_address;
    reg [10:0]rx_frame_size;
    reg [31:0]rx_frame_check_sequence;

    assign rx_frame_size_o = rx_frame_size;
   
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
    always @ ( posedge tx_clock_i or posedge tx_reset_i)
    begin : tx_fsm_sync
        reg [1:0]update_fcs;
        reg [7:0]data_out;
        if ( tx_reset_i == 1'b1 ) 
        begin
            tx_state <= 'b0;
            mii_tx_enable_o <= 1'b0;
            tx_busy_o <= 1'b1;
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
                            tx_state <= 'b1000;
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
    end
    always @ ( posedge rx_clock_i or posedge rx_reset_i)
    begin : rx_fsm_sync
        if ( rx_reset_i == 1'b1 ) 
        begin
            rx_state <= 'b0;
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
                    rx_frame_size <= 0;
                    rx_frame_check_sequence <= { 32{1'b1} };
                    if ( mii_rx_frame_i == 1'b1 ) 
                    begin
                        if ( mii_rx_byte_received_i == 1'b1 ) 
                        begin
                            case ( mii_rx_data_i ) 
                            8'b11010101:
                            begin
                                rx_state <= 1'b1;
                            end
                            8'b01010101:
                            begin
                            end
                            default :
                            begin
                                rx_state <= 2'b11;
                            end
                            endcase
                        end
                        if ( mii_rx_error_i == 1'b1 ) 
                        begin
                            rx_state <= 2'b11;
                        end
                    end
                end
                'b1:
                begin
                    rx_frame_o <= 1'b1;
                    rx_byte_received_o <= mii_rx_byte_received_i;
                    if ( mii_rx_frame_i == 1'b0 ) 
                    begin
                        rx_state <= 'b0;
                        if ( ( ( ( mii_rx_error_i == 1'b1 ) | ( rx_frame_check_sequence != 32'b11000111000001001101110101111011 ) ) | ( rx_frame_size < ( ( 46 + 6 ) + ( 32 / 8 ) ) ) ) | ( rx_frame_size > ( ( 1500 + 6 ) + ( 32 / 8 ) ) ) ) 
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
                endcase
            end
        end
    end
endmodule 
