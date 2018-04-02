obj-m += knockd.o

all: clean build deploy

stop:
	-rmmod knockd

deploy:
	-rmmod knockd
	insmod knockd.ko

build:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

clean:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean
