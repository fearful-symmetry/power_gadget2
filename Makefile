CFLAGS=-g -Wall -Wextra -Wundef -Wimplicit -Wpedantic
CC=clang

all: rapl_lib_shared rapl_lib_static power_gadget_static

rapl_lib_shared: 
	$(CC) $(CFLAGS) -fpic -c msr.c cpuid.c rapl.c 
	$(CC) $(CFLAGS) -shared -o librapl.so msr.o cpuid.o rapl.o

rapl_lib_static: 
	$(CC) $(CFLAGS) -c msr.c cpuid.c rapl.c 
	ar rcs librapl.a msr.o cpuid.o rapl.o

power_gadget_static: 
	$(CC) $(CFLAGS) power_gadget.c -I. -o power_gadget ./librapl.a -L. -lm 

power_gadget: 
	 $(CFLAGS) power_gadget.c -I. -o power_gadget -L. -lm -lrapl 

gprof: CFLAGS = -pg
gprof: all
	./power_gadget -e 100 -d 60 >/dev/null 2>&1
	gprof power_gadget > power_gadget.gprof
	rm -f gmon.out
	make clean

clean: 
	rm -f power_gadget librapl.so librapl.a msr.o cpuid.o rapl.o 
