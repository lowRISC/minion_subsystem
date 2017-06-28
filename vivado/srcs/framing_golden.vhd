-- This file is part of the ethernet_mac project.
--
-- For the full copyright and license information, please read the
-- LICENSE.md file that was distributed with this source code.

-- MAC sublayer functionality (en-/decapsulation, FCS, IPG)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity framing is

  port(
		tx_reset_i             : in  std_ulogic;
		tx_clock_i             : in  std_ulogic;
		rx_reset_i             : in  std_ulogic;
		rx_clock_i             : in  std_ulogic;

		-- MAC address of this station
		-- Must not change after either reset is deasserted
		-- Used for
		-- * dropping received packets when the destination address differs from both this one and the broadcast address
		-- * inserting as source address in transmitted packets when the first byte of the source address in the data stream is all-ones
		mac_address_i          : in  std_ulogic_vector(47 downto 0);

		-- For details on the signals, see the port list of mii_gmii

		-- TX from client logic
		-- The length/type field is considered part of the data!
		-- It is not interpreted by the framing layer at all.
		tx_enable_i            : in  std_ulogic;
		tx_data_i              : in  std_ulogic_vector(7 downto 0);
		tx_byte_sent_o         : out std_ulogic;
                tx_fcs_o               : out std_ulogic_vector(31 downto 0);
		-- Do not start new frames while asserted
		-- (continuing the previous one is alright)
		tx_busy_o              : out std_ulogic;

		-- RX to client logic 
		rx_frame_o             : out std_ulogic;
		rx_data_o              : out std_ulogic_vector(7 downto 0);
		rx_byte_received_o     : out std_ulogic;
		rx_error_o             : out std_ulogic;
		rx_frame_size_o        : out std_logic_vector(10 downto 0);
                rx_fcs_o               : out std_ulogic_vector(31 downto 0);
                
		-- TX to MII
		mii_tx_enable_o        : out std_ulogic;
		mii_tx_data_o          : out std_ulogic_vector(7 downto 0);
		mii_tx_byte_sent_i     : in  std_ulogic;
		mii_tx_gap_o           : out std_ulogic;

		-- RX from MII
		mii_rx_frame_i         : in  std_ulogic;
		mii_rx_data_i          : in  std_ulogic_vector(7 downto 0);
		mii_rx_byte_received_i : in  std_ulogic;
		mii_rx_error_i         : in  std_ulogic
	);
end entity;

architecture rtl of framing is
	-- CRC32 value type
	subtype t_crc32 is std_ulogic_vector(31 downto 0);
	constant CRC32_POSTINVERT_MAGIC : t_crc32 := X"C704DD7B";
	constant CRC32_BYTES : positive := (t_crc32'length / 8);
	-- One Ethernet interface byte
	subtype t_ethernet_data is std_ulogic_vector(7 downto 0);
	-- Ethernet speed, values defined below
	subtype t_ethernet_speed is std_ulogic_vector(1 downto 0);
	-- Ethernet MAC layer address
	constant MAC_ADDRESS_BYTES : std_logic_vector(2 downto 0) := "110";
	subtype t_mac_address is std_ulogic_vector(47 downto 0);
	-- Use utility.reverse_bytes to convert from the canoncial form to the internal representation
	-- Example: signal m : t_mac_address := reverse_bytes(x"04AA19BCDE10");
	-- m then represents the canoncial address 04-AA-19-BC-DE-10
	-- Broadcast address
	constant BROADCAST_MAC_ADDRESS : t_mac_address := x"FFFFFFFFFFFF";	

	-- Speed constants
	constant SPEED_1000MBPS    : t_ethernet_speed := "10";
	constant SPEED_100MBPS     : t_ethernet_speed := "01";
	constant SPEED_10MBPS      : t_ethernet_speed := "00";
	constant SPEED_UNSPECIFIED : t_ethernet_speed := "11";

-- Utility functions

	-- Return the reverse of the given vector
	function reverse_vector(vec : in std_ulogic_vector) return std_ulogic_vector;
	-- Extract a byte out of a vector
	function extract_byte(vec : in std_ulogic_vector(47 downto 0); byteno : in std_logic_vector(2 downto 0)) return std_ulogic_vector;
        -- Get a specific byte out of the given CRC32 suitable for transmission as Ethernet FCS
        function fcs_output_byte(fcs : t_crc32; byte : integer) return t_ethernet_data;

	-- Preamble/SFD data in IEEE 802.3 clauses 4.2.5 and 4.2.6 is denoted LSB first, so they appear reversed here
	constant PREAMBLE_DATA              : t_ethernet_data := "01010101";
	--constant PREAMBLE_LENGTH : positive := 7;
	constant START_FRAME_DELIMITER_DATA : t_ethernet_data := "11010101";
	constant PADDING_DATA               : t_ethernet_data := "00000000";

	-- Data is counted from the end of the SFD to the beginning of the frame check sequence, exclusive
	constant MIN_FRAME_DATA_BYTES : positive := 46 + 2 + 6 + 6; -- bytes
	constant MAX_FRAME_DATA_BYTES : positive := 1500 + 2 + 6 + 6; -- bytes

	constant INTERPACKET_GAP_BYTES : positive := 12; -- bytes

	-- 11 bits are sufficient for 2048 bytes, Ethernet can only have 1518
	constant PACKET_LENGTH_BITS : positive := 11;
	constant MAX_PACKET_LENGTH  : positive := (2 ** PACKET_LENGTH_BITS) - 1;
	subtype t_packet_length is unsigned((PACKET_LENGTH_BITS - 1) downto 0);

	-- Update CRC old_crc by one bit (input) using a given polynomial
	function update_crc(old_crc : std_ulogic_vector; input : std_ulogic; polynomial : std_ulogic_vector) return std_ulogic_vector;
	-- Update CRC old_crc by an arbitrary number of bits (input) using a given polynomial
	function update_crc(old_crc : std_ulogic_vector; input : std_ulogic_vector; polynomial : std_ulogic_vector) return std_ulogic_vector;

	-- As defined in IEEE 802.3 clause 3.2.9
	-- x^32 + x^26 + x^23 + x^22 + x^16 + x^12 + x^11 + x^10 + x^8 + x^7 + x^5 + x^4 + x^2 + x + 1
	constant CRC32_POLYNOMIAL : std_ulogic_vector(32 downto 0) := (
		32 | 26 | 23 | 22 | 16 | 12 | 11 | 10 | 8 | 7 | 5 | 4 | 2 | 1 | 0 => '1',
		others => '0'
	);

	-- Value that remains as CRC value when incoming data including the original FCS is piped through update_crc32 
	-- and the FCS is correct.
	-- Usually this would be zero, but the inversion of the FCS in clause 3.2.9 e changes it to this magic value.
	-- Transmission
	type t_tx_state is (
		TX_IDLE,
		-- TX_PREMABLE1 is not needed: first preamble byte is transmitted directly in TX_IDLE when start of transmission
		-- is detected.
		TX_PREAMBLE2,
		TX_PREAMBLE3,
		TX_PREAMBLE4,
		TX_PREAMBLE5,
		TX_PREAMBLE6,
		TX_PREAMBLE7,
		TX_START_FRAME_DELIMITER,
		TX_CLIENT_DATA_WAIT_SOURCE_ADDRESS,
		TX_SOURCE_ADDRESS,
		TX_CLIENT_DATA,
		TX_PAD,
		TX_FRAME_CHECK_SEQUENCE2,
		TX_FRAME_CHECK_SEQUENCE3,
		TX_FRAME_CHECK_SEQUENCE4,
		TX_INTERPACKET_GAP
	);

	signal tx_state                   : t_tx_state;
	signal tx_frame_check_sequence    : t_crc32;
	signal tx_padding_required        : natural range 0 to MIN_FRAME_DATA_BYTES + 4 + 1;
	signal tx_interpacket_gap_counter : std_logic_vector(3 downto 0);
	signal tx_mac_address_byte        : std_logic_vector(2 downto 0);

	-- Reception
	type t_rx_state is (
		RX_WAIT_START_FRAME_DELIMITER,
		RX_DATA,
		RX_ERROR,
		RX_SKIP_FRAME
	);

	signal rx_state                : t_rx_state;
	signal rx_frame_check_sequence : t_crc32;
	subtype t_rx_frame_size is natural range 0 to MAX_FRAME_DATA_BYTES + CRC32_BYTES + 1;
	signal rx_frame_size       : t_rx_frame_size;
	signal rx_is_group_address     : std_ulogic;
	signal rx_mac_address_byte : std_logic_vector(2 downto 0);

	function extract_byte(vec : in std_ulogic_vector(47 downto 0); byteno : in std_logic_vector(2 downto 0)) return std_ulogic_vector is
	begin
    case byteno is
      when "000" => return vec(7 downto 0);
      when "001" => return vec(15 downto 8);
      when "010" => return vec(23 downto 16);
      when "011" => return vec(31 downto 24);
      when "100" => return vec(39 downto 32);
      when "101" => return vec(47 downto 40);
      when others => return "00000000";
    end case;
	end function;

        function fcs_output_byte(fcs : t_crc32; byte : integer) return t_ethernet_data is

		variable reversed : t_crc32;
		variable out_byte : std_ulogic_vector(7 downto 0);
		variable inverted : std_ulogic_vector(7 downto 0);
	begin
		-- Reverse and invert the whole CRC32, then get the needed byte out
		reversed := reverse_vector(fcs);
		out_byte := reversed((((byte + 1) * 8) - 1) downto byte * 8);
		inverted := not out_byte;
		return inverted;
	end function;

                function reverse_vector(vec : in std_ulogic_vector) return std_ulogic_vector is
		variable result : std_ulogic_vector(vec'range);
		alias rev_vec   : std_ulogic_vector(vec'reverse_range) is vec;
	begin
		for i in rev_vec'range loop
			result(i) := rev_vec(i);
		end loop;
		return result;
	end function;
	
	function update_crc(old_crc : std_ulogic_vector; input : std_ulogic; polynomial : std_ulogic_vector) return std_ulogic_vector is
		variable new_crc  : std_ulogic_vector(old_crc'range);
		variable feedback : std_ulogic;
	begin
		assert not old_crc'ascending report "CRC argument must have descending range";
		-- Simple calculation with LFSR
		new_crc  := old_crc;
		feedback := new_crc(new_crc'high) xor input;

		new_crc  := std_ulogic_vector(unsigned(new_crc) sll 1);
		if (feedback = '1') then
			new_crc := new_crc xor polynomial(polynomial'high - 1 downto 0);
		end if;

		return new_crc;
	end function;

	-- Let the synthesizer figure out how to compute the checksum in parallel
	-- for any number of bits
	function update_crc(old_crc : std_ulogic_vector; input : std_ulogic_vector; polynomial : std_ulogic_vector) return std_ulogic_vector is
		variable new_crc : std_ulogic_vector(old_crc'range);
	begin
		assert not old_crc'ascending report "CRC argument must have descending range";
		assert not input'ascending report "Input argument must have descending range";
		new_crc := old_crc;

		-- Start with LSB
		for i in input'low to input'high loop
			new_crc := update_crc(new_crc, input(i), polynomial);
		end loop;
		
		return new_crc;
	end function;

	function update_crc32(old_crc : t_crc32; input : std_ulogic) return t_crc32 is
	begin
		return update_crc(old_crc, input, CRC32_POLYNOMIAL);
	end function;
	
	function update_crc32(old_crc : t_crc32; input : std_ulogic_vector) return t_crc32 is
	begin
		return update_crc(old_crc, input, CRC32_POLYNOMIAL);
	end function;
	
begin
  rx_frame_size_o <= std_logic_vector(to_unsigned(rx_frame_size,11));
  rx_fcs_o <= rx_frame_check_sequence;
  tx_fcs_o <= tx_frame_check_sequence;
  
	-- Pass mii_tx_byte_sent_i through directly as long as data is being transmitted
	-- to avoid having to prefetch data in the synchronous process
	tx_byte_sent_o <= '1' when ((tx_state = TX_CLIENT_DATA or tx_state = TX_CLIENT_DATA_WAIT_SOURCE_ADDRESS or tx_state = TX_SOURCE_ADDRESS) and mii_tx_byte_sent_i = '1') else '0';

	-- Transmission state machine
	tx_fsm_sync : process(tx_reset_i, tx_clock_i)
		variable update_fcs : boolean;
		variable data_out   : std_ulogic_vector(7 downto 0);
	begin
		if tx_reset_i = '1' then
			tx_state        <= TX_IDLE;
			mii_tx_enable_o <= '0';
			tx_busy_o       <= '1';
                        tx_padding_required <= 0;
		elsif rising_edge(tx_clock_i) then
			mii_tx_enable_o <= '0';
			tx_busy_o       <= '0';
			if tx_state = TX_IDLE then
				if tx_enable_i = '1' then
					-- Jump straight into preamble to save a clock cycle of latency
					tx_state        <= TX_PREAMBLE2;
					mii_tx_data_o   <= PREAMBLE_DATA;
					mii_tx_enable_o <= '1';
					mii_tx_gap_o    <= '0';
					tx_busy_o       <= '1';
				end if;
			else
				-- Keep TX enable and busy asserted at all times
				mii_tx_enable_o <= '1';
				tx_busy_o       <= '1';

				-- Use mii_tx_byte_sent_i as clock enable
				if mii_tx_byte_sent_i = '1' then
					mii_tx_gap_o <= '0';
					data_out     := (others => '0');
					update_fcs   := FALSE;

					case tx_state is
						when TX_IDLE =>
							-- Handled above, cannot happen here
							null;
						when TX_PREAMBLE2 | TX_PREAMBLE3 | TX_PREAMBLE4 | TX_PREAMBLE5 | TX_PREAMBLE6 =>
							tx_state <= t_tx_state'succ(tx_state);
							data_out := PREAMBLE_DATA;
						when TX_PREAMBLE7 =>
							tx_state <= TX_START_FRAME_DELIMITER;
							data_out := PREAMBLE_DATA;
						when TX_START_FRAME_DELIMITER =>
							tx_state                <= TX_CLIENT_DATA;--_WAIT_SOURCE_ADDRESS;
							data_out                := START_FRAME_DELIMITER_DATA;
							-- Load padding register
							tx_padding_required     <= MIN_FRAME_DATA_BYTES;
							-- Load FCS
							-- Initial value is 0xFFFFFFFF which is equivalent to inverting the first 32 bits of the frame
							-- as required in clause 3.2.9 a
							tx_frame_check_sequence <= (others => '1');
							-- Load MAC address counter
							tx_mac_address_byte     <= "000";
						when TX_CLIENT_DATA_WAIT_SOURCE_ADDRESS =>
							data_out   := tx_data_i;
							update_fcs := TRUE;
							-- Skip destination address
							if tx_mac_address_byte < MAC_ADDRESS_BYTES then
								tx_mac_address_byte <= tx_mac_address_byte + "001";
							else
								-- All-ones means that we should insert the source address here
								if tx_data_i = x"FF" then
									tx_state            <= TX_SOURCE_ADDRESS;
									-- Override client data with first source address byte
                                    data_out := mac_address_i(7 downto 0);
 									-- Second byte is to be sent in next cycle
									tx_mac_address_byte <= "001";
								else
									-- Transmit as usual, skip TX_SOURCE_ADDRESS
									tx_state <= TX_CLIENT_DATA;
								end if;
							end if;
							
							-- Bail out from here if transmission was aborted
							-- Note that this should not happen under normal circumstances as the
							-- Ethernet frame would be far too short.
							if tx_enable_i = '0' then
								tx_state <= TX_PAD;
								data_out := PADDING_DATA;
							end if;
						when TX_SOURCE_ADDRESS =>
							data_out   := extract_byte(mac_address_i, tx_mac_address_byte);
							update_fcs := TRUE;
							if tx_mac_address_byte < (MAC_ADDRESS_BYTES - "001") then
								tx_mac_address_byte <= tx_mac_address_byte + "001";
							else
								-- Address completely sent when tx_mac_address_byte reaches 5
								-- Pass on client data again in next cycle
								tx_state <= TX_CLIENT_DATA;
							end if;
						when TX_CLIENT_DATA =>
							data_out   := tx_data_i;
							update_fcs := TRUE;
							if tx_enable_i = '0' then
								-- No more user data was available, next value has to be sent
								-- in this clock cycle already
								if tx_padding_required = 0 then
									-- Send FCS byte 1 now, byte 2 in next cycle
									tx_state   <= TX_FRAME_CHECK_SEQUENCE2;
									data_out   := fcs_output_byte(tx_frame_check_sequence, 0);
									update_fcs := FALSE;
								else
									tx_state <= TX_PAD;
									data_out := PADDING_DATA;
								end if;
							end if;
						when TX_PAD =>
							data_out   := PADDING_DATA;
							update_fcs := TRUE;
							if tx_padding_required = 0 then
								-- When required=0, previous one was the last one -> send FCS
								tx_state   <= TX_FRAME_CHECK_SEQUENCE2;
								data_out   := fcs_output_byte(tx_frame_check_sequence, 0);
								update_fcs := FALSE;
							end if;
						when TX_FRAME_CHECK_SEQUENCE2 =>
							tx_state <= t_tx_state'succ(tx_state);
							data_out := fcs_output_byte(tx_frame_check_sequence, 1);
						when TX_FRAME_CHECK_SEQUENCE3 =>
							tx_state <= t_tx_state'succ(tx_state);
							data_out := fcs_output_byte(tx_frame_check_sequence, 2);
						when TX_FRAME_CHECK_SEQUENCE4 =>
							tx_state                   <= TX_INTERPACKET_GAP;
							data_out                   := fcs_output_byte(tx_frame_check_sequence, 3);
							-- Load IPG counter with initial value
							tx_interpacket_gap_counter <= (others => '0');
						when TX_INTERPACKET_GAP =>
							-- Only state where the MAC is still busy but no data is actually sent
							mii_tx_gap_o <= '1';
							if tx_interpacket_gap_counter = INTERPACKET_GAP_BYTES - 1 then
								-- Last IPG byte is transmitted in this cycle
								tx_state <= TX_IDLE;
							else
								tx_interpacket_gap_counter <= tx_interpacket_gap_counter + 1;
							end if;
					end case;

					mii_tx_data_o <= data_out;
					if update_fcs then
						tx_frame_check_sequence <= update_crc32(tx_frame_check_sequence, data_out);
					end if;

					if tx_state = TX_CLIENT_DATA_WAIT_SOURCE_ADDRESS or tx_state = TX_SOURCE_ADDRESS or tx_state = TX_CLIENT_DATA or tx_state = TX_PAD then
						-- Decrement required padding
						if tx_padding_required > 0 then
							tx_padding_required <= tx_padding_required - 1;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;

	-- Reception state machine
	rx_fsm_sync : process(rx_reset_i, rx_clock_i)
	begin
		if rx_reset_i = '1' then
                  rx_state <= RX_WAIT_START_FRAME_DELIMITER;
		elsif rising_edge(rx_clock_i) then
                  rx_error_o         <= '0';
			rx_data_o          <= mii_rx_data_i;
			rx_byte_received_o <= '0';
			rx_frame_o         <= '0';

			case rx_state is
				when RX_WAIT_START_FRAME_DELIMITER =>
					-- Reset MAC address detection
					rx_mac_address_byte     <= "000";
					rx_is_group_address         <= '1';
					  -- Reset frame size and FCS
                                          rx_frame_size           <= 0;
					  -- Initial value is 0xFFFFFFFF which is equivalent to inverting the first 32 bits of the frame
					  -- as required in clause 3.2.9 a
					  rx_frame_check_sequence <= (others => '1');

					if mii_rx_frame_i = '1' then
						if mii_rx_byte_received_i = '1' then
							case mii_rx_data_i is
								when START_FRAME_DELIMITER_DATA =>
									rx_state <= RX_DATA;
								when PREAMBLE_DATA =>
									-- Do nothing, wait for end of preamble
									null;
								when others =>
									-- The frame needs to be thrown away, but there is no need to 
									-- inform the higher layer since nothing of value was actually "received" anyway.
									rx_state <= RX_SKIP_FRAME;
							end case;
						end if;
						if mii_rx_error_i = '1' then
							-- Same here						
							rx_state <= RX_SKIP_FRAME;
						end if;
					end if;
				when RX_DATA =>
					rx_frame_o         <= '1';
					rx_byte_received_o <= mii_rx_byte_received_i;
					if mii_rx_frame_i = '0' then
						rx_state <= RX_WAIT_START_FRAME_DELIMITER;
						-- Remaining FCS after parsing whole packet + FCS needs to be a specific value
						if mii_rx_error_i = '1' or rx_frame_check_sequence /= CRC32_POSTINVERT_MAGIC or rx_frame_size < MIN_FRAME_DATA_BYTES + CRC32_BYTES or rx_frame_size > MAX_FRAME_DATA_BYTES + CRC32_BYTES then
							rx_error_o <= '1';
						end if;
					else
						if mii_rx_byte_received_i = '1' then
							-- Update FCS check
							rx_frame_check_sequence <= update_crc32(rx_frame_check_sequence, mii_rx_data_i);
							-- Increase frame size
							if rx_frame_size < t_rx_frame_size'high then
								rx_frame_size <= rx_frame_size + 1;
							end if;
							-- Check destination MAC address (first 6 bytes of packet)
							if rx_mac_address_byte < MAC_ADDRESS_BYTES then
								-- First byte determines whether the address is an individual or group address
								if rx_mac_address_byte = "000" then
									if mii_rx_data_i(0) = '0' then
										-- LSB of the address is zero: packet is destined for an individual entity
										rx_is_group_address <= '0';
										-- Check first address byte
										if mii_rx_data_i /= extract_byte(mac_address_i, rx_mac_address_byte) then
											-- Packet is not destined for us -> drop it
											rx_state <= RX_ERROR;
										end if;
									end if;
									-- If not: It is a group address packet -> do not drop it and do not check the address further
								elsif rx_is_group_address = '0' then
									-- Check other MAC address bytes only if we know it doesn't have a group destination address
									if mii_rx_data_i /= extract_byte(mac_address_i, rx_mac_address_byte) then
										-- Packet is not destined for us -> drop it 
										rx_state <= RX_ERROR;
									end if;
								end if;

								rx_mac_address_byte <= rx_mac_address_byte + "001";
							end if;
						end if;
						if mii_rx_error_i = '1' then
							-- Skip the rest of the frame and tell the higher layer
							rx_state <= RX_ERROR;
						end if;
					end if;
				when RX_SKIP_FRAME =>
					-- Skip the currently receiving frame without signaling the higher layer
					if mii_rx_frame_i = '0' then
						rx_state <= RX_WAIT_START_FRAME_DELIMITER;
					end if;
				when RX_ERROR =>
					-- Skip the currently receiving frame and signal the higher layer
					rx_frame_o <= '1';
					rx_error_o <= '1';
					if mii_rx_frame_i = '0' then
						rx_state <= RX_WAIT_START_FRAME_DELIMITER;
					end if;
			end case;
		end if;
	end process;

end architecture;
