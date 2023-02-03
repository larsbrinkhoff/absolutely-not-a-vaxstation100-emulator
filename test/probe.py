#!/usr/bin/env python3

import sys
import socket
import subprocess

csr = [0x0040, 0, 0, 0, 0, 0, 0, 0]
memory = [0] * 262144

#Foreground/background map.
fbmap = [0x40, 0x40, 0x40, 0x40, 0x45, 0x45, 0x45, 0x45,
	 0x4a, 0x4a, 0x4a, 0x4a, 0x4f, 0x4f, 0x4f, 0x4f,
	 0x40, 0x44, 0x48, 0x22, 0x41, 0x45, 0x49, 0x4d,
	 0x42, 0x46, 0x4a, 0x4e, 0x00, 0x47, 0x4b, 0x4f,
	 0x40, 0x41, 0x42, 0x00, 0x44, 0x45, 0x46, 0x47,
	 0x48, 0x49, 0x4a, 0x4b, 0x22, 0x4d, 0x4e, 0x4f,
	 0x40, 0x45, 0x4a, 0x4f, 0x40, 0x45, 0x4a, 0x4f,
	 0x40, 0x45, 0x4a, 0x4f, 0x40, 0x45, 0x4a, 0x4f];

#Single source map.
ssmap = [0x40, 0x41, 0x42, 0x00, 0x44, 0x45, 0x46, 0x47,
	 0x48, 0x49, 0x4a, 0x4b, 0x22, 0x4d, 0x4e, 0x4f,
	 0x40, 0x44, 0x48, 0x22, 0x41, 0x45, 0x49, 0x4d,
	 0x42, 0x46, 0x4a, 0x4e, 0x00, 0x47, 0x4b, 0x4f]

COPY_AREA = 1
DRAW_CURVE = 2
PRINT_TEXT = 3
FLOOD_AREA = 4
LOAD_CURSOR = 5
SET_CURSOR_POSITION = 6
ATTACH_CURSOR = 7
GET_CURSOR_POSITION = 8
MOVE_OBJECT = 9
REPORT_STATUS = 10
FILL_AREA = 11
GET_MOUSE_POSITION = 12
SET_MOUSE_CHARACTERISTICS = 13
GET_TABLET_POSITION = 14
SET_POINTING_DEVICE_REPORTING = 15
SET_TABLET_CHARACTERISTICS = 16

def noop(s):
    yield

def end(s):
    global vs100
    vs100.kill()
    sys.exit(0)

next = noop

def send_xmit_on(s):
    csr[0] |= 0x1000
    s.sendall(b'\001')

def send_xmit_off(s):
    csr[0] &= ~0x1000
    s.sendall(b'\002')

def send_csr(s, n):
    s.sendall(b'\004' + n.to_bytes(1, 'big') + csr[n].to_bytes(2, 'big'))

def set_csr(s, n, x):
    csr[n] = x
    send_csr(s, n)

def send_command(s, c, p=None):
    if not p == None:
        set_csr(s, 3, p & 0xFFFF)
        set_csr(s, 4, p >> 16)
    csr[0] &= ~0x3F
    csr[0] |= (c << 1) | 1
    send_csr(s, 0)

def send_data(s, data):
    s.sendall(b'\007' + data.to_bytes(2, 'big'))

def send_init(s):
    send_command(s, 1)

def nothing_done(s):
    print("nothing done")

def send_start(s):
    global next
    next = send_copy_area
    send_command(s, 3, 0x1000)

def send_copy_area(s):
    global next
    srcx = 1
    srcy = 0
    width = 48
    height = 2
    dstx = 96
    dsty = 0
    clips = []
    clipcount = len(clips)
    func = 3
    mska = 0x10000
    mskx = 50
    msky = 0

    func = ssmap[func]

    x = COPY_AREA             #opcode
    x |= 1 << 8               #source
    if (mska != 0):
        x |= 1 << 11          #mask
    x |= (func >> 4) << 17    #map
    x |= 0 << 20              #clipping
    memory[0] = x & 0xFFFF
    memory[1] = x >> 16

    memory[2] = 0             #next
    memory[3] = 0

    x = 0x100000
    memory[4] = x & 0xFFFF    #source address
    memory[5] = x >> 16
    memory[6] = 1088          #source width
    memory[7] = 864           #source height
    memory[8] = 1             #source bits per pixel
    memory[9] = srcx          #source offset x
    memory[10] = srcy         #source offset y

    #subbitmap sourcemask 11 12 13 14 15 16 17
    memory[11] = mska & 0xFFFF #mask address
    memory[12] = mska >> 16
    memory[13] = 1088         #mask width
    memory[14] = 864          #mask height
    memory[15] = 1            #mask bits per pixel
    memory[16] = mskx         #mask offset x
    memory[17] = msky         #mask offset y
    memory[18] = width        #mask width
    memory[19] = height       #mask height

    x = 0x100000
    memory[20] = x & 0xFFFF   #destination address
    memory[21] = x >> 16
    memory[22] = 1088         #destination width
    memory[23] = 864          #destination height
    memory[24] = 1            #destination bits per pixel
    memory[25] = dstx         #destination offset x
    memory[26] = dsty         #destination offset y

    memory[27] = func & 0xF
    memory[28] = 0

    if clipcount == 1:
        memory[1] |= 1 << 4;  #clipping
        memory[29] = clips[0][0]
        memory[30] = clips[0][1]
        memory[31] = clips[0][2]
        memory[32] = clips[0][3]
    elif clipcount > 1:
        memory[1] |= 2 << 4;  #clipping
        memory[29] = 0
        memory[30] = 0
        memory[31] = clipcount

    next = end
    send_command(s, 2, 0x080000)

def send_firmware(s):
    global next
    print("send firmware")
    f = open("drivers/X10R4/fw-235.bin", mode="rb")
    data = f.read()
    f.close()
    a = 0x30 >> 1
    n = 0
    for x1, x2 in zip(data[0::2], data[1::2]):
        memory[a] = (x1 << 8) | x2
        a += 1
        n += 2
    memory[0] = 0x80
    memory[1] = 0
    memory[5] = n 
    memory[6] = 0
    memory[7] = 0x0030
    memory[8] = 0x0008
    memory[9] = 0x1000
    memory[10] = 0
    next = send_start
    send_command(s, 2, 0x080000)

def init_done(s):
    global next
    print("init done")
    memory[0] = 0x81
    memory[1] = 0
    next = send_firmware
    send_command(s, 2, 0x080000)

def command_done(s):
    global next
    print("command done")
    next(s)

def start_done(s):
    global next
    print("start done")
    next(s)

def powerup_done(s):
    print("powerup done")
    send_init(s)

reason = {
    0x0000: nothing_done,
    0x0001: init_done,
    0x0002: command_done,
    0x0004: start_done,
    0x0080: powerup_done
}

def recv_xmit_on(s):
    print("xmit on")
    csr[0] |= 0x4000

def recv_xmit_off(s):
    print("xmit off")
    csr[0] &= ~0x4000

def recv_int(s):
    print("interrupt")
    irr = csr[1]
    set_csr(s, 1, 0)
    reason[irr](s)

def recv_csr(s):
    data = s.recv(3)
    n = data[0]
    csr[n] = (data[1] << 8) | data[2]
    print("CSR%d %04X" % (n, csr[n]))

def recv_read16(s):
    data = s.recv(4)
    a = data[0] << 24
    a |= data[1] << 16
    a |= data[2] << 8
    a |= data[3]
    send_data(s, memory[a >> 1])

def recv_write16(s):
    data = s.recv(6)

dispatch = {
    1: recv_xmit_on,
    2: recv_xmit_off,
    3: recv_int,
    4: recv_csr,
    6: recv_read16,
    10: recv_write16
}

def fibre_recv(s):
    data = s.recv(1)
    if len(data) == 0:
        sys.exit(0)
    dispatch[data[0]](s)

if __name__ == '__main__':
    global vs100
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.bind(("localhost", 54321))
    sock.listen(1)
    f = open(sys.argv[1], "w")
    vs100 = subprocess.Popen(["./vs100"], stdout=f, stderr=f)
    s, a = sock.accept()
    send_xmit_on(s)
    while True:
        fibre_recv(s)
