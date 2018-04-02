all: build

build:
		docker build -t vulnstruts .

run:
		docker run -d vulnstruts

exploit:
		python exploitS2-045-cmd.py ${TARGET_IP}:8080 whoami
