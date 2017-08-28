import serial
import array
import time
import threading
import sys
import os
import signal

port = serial.Serial("/dev/ttyUSB1", baudrate=9600, timeout=1.0)

buffer = ""

rx_pkt_counter = 0
tx_pkt_counter = 0

this_is_the_end = False

time.sleep(1)

#                              start    TC   APP   SEQ   PKT ACK   SER   SER   CRC  stop
#                               flag          ID  flag   LEN      type  subT        flag
test_packet = array.array('B', [0x7E, 0x18, 0x01, 0xC0, 0x3C,  0, 0x11, 0x01, 0x00, 0x7F]).tostring()

#            start    TM   APP   SEQ   PKT ACK   SER   SER   CRC  stop
#             flag          ID  flag   LEN      type  subT        flag
cmp_packet = [0x7E, 0x08, 0x02, 0xC0, 0x3C,  0, 0x11, 0x02, 0x00, 0x7F]

def write_to_port():
    global port, tx_pkt_counter, this_is_the_end
    time.sleep(2)
    while not this_is_the_end:
        port.write(test_packet)
        tx_pkt_counter += 1
        time.sleep(0.5)

def read_from_port():
    global port, rx_pkt_counter, this_is_the_end, buffer
    while not this_is_the_end:
        rcv = port.read(1)
        if len(rcv) > 0:
            buffer += rcv
            #print buffer.encode('hex')

def find_packet():
    global buffer
    start = 0
    while not this_is_the_end:
        for i, c in enumerate(buffer):
            if ord(c) == 0x7E:
                #print "This is a good start"
                start = True
                s_index = i
            elif ord(c) == 0x7F:
                #print "Are we there yet?", start
                if start:
                    check_packet(buffer[s_index:i+1], (i+1)-s_index)
                buffer = buffer[i+1:]
                break
        time.sleep(0.1)

def check_packet(buf, pkt_len):
    global rx_pkt_counter,tx_pkt_counter
    #print buf.encode('hex'), pkt_len
    if pkt_len == 10:
        rx_pkt_counter += 1
        #print "good to go"

def sg_handler(signal, frame):
    global this_is_the_end
    print "Time to go, bye!"
    this_is_the_end = True

def testing():
    global port, this_is_the_end, buffer
    thread_rx  = threading.Thread(target=read_from_port)
    thread_tx  = threading.Thread(target=write_to_port)
    thread_ch  = threading.Thread(target=find_packet)

    thread_rx.start()
    thread_tx.start()
    thread_ch.start()
    while not this_is_the_end:
        print "Lost packets", tx_pkt_counter - rx_pkt_counter, "/ Rx, Tx:",  rx_pkt_counter, tx_pkt_counter
        time.sleep(1)
    thread_rx.join()
    thread_tx.join()
    thread_ch.join()
    port.close()

if __name__ == '__main__':
    signal.signal(signal.SIGINT, sg_handler)
    testing()
