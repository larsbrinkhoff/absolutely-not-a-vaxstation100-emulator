CFLAGS=-Wall -g -I. -Icommon `sdl2-config --cflags`
LDLIBS=`sdl2-config --libs` -lSDL2_image
LDLIBS+=-lSDL2_net
LDLIBS+=-lGL

OBJS=bba.o cpu.o ddt.o fibre.o host.o irq.o lk201.o mouse.o network.o \
     status.o tablet.o video.o
COMMON=common/event.o common/sdl.o common/opengl.o

all: vs100 font-to-pbm icon-to-pbm

vs100: $(OBJS) $(COMMON) check.o
	$(CC) -o $@ $^ $(LDLIBS)

font-to-pbm: font-to-pbm.c
icon-to-pbm: icon-to-pbm.c

clean:
	rm -f vs100 font-to-pbm icon-to-pbm $(OBJS) $(COMMON)

bba.o: bba.c vs100.h
cpu.o: cpu.c vs100.h common/event.h
fibre.o: fibre.c vs100.h
host.o: host.c vs100.h
irq.o: irq.c vs100.h
lk201.o: lk201.c mc2661.c vs100.h common/event.h
mouse.o: mouse.c vs100.h
status.o: status.c vs100.h
socket.o: socket.c vs100.h
tablet.o: tablet.c mc2661.c vs100.h
video.o: video.c mc2661.c vs100.h
common/event.o: common/event.c common/event.h
common/sdl.o: common/sdl.c common/xsdl.h
