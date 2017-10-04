import socket

import RPi.GPIO as GPIO

GPIO.setmode(GPIO.BCM)

GPIO11 = 2
GPIO12 = 3

GPIO21 = 14 # todo
GPIO22 = 15 # todo

GPIO.setup(GPIO11, GPIO.OUT)
GPIO.setup(GPIO12, GPIO.OUT)
GPIO.setup(GPIO21, GPIO.OUT)
GPIO.setup(GPIO22, GPIO.OUT)

p = GPIO.PWM(GPIO11, 1000)
p2 = GPIO.PWM(GPIO12, 1000)
p3 = GPIO.PWM(GPIO21, 1000)
p4 = GPIO.PWM(GPIO22, 1000)
p.start(0)
p2.start(0)
p3.start(0)
p4.start(0)

#servo.set_servo(GPIO21, 2000)

#raw_input('Enter your input:')

UDP_IP = "0.0.0.0"
UDP_PORT = 8888

sock = socket.socket(socket.AF_INET, # Internet
                     socket.SOCK_DGRAM) # UDP
sock.bind((UDP_IP, UDP_PORT))

while True:
    data, addr = sock.recvfrom(1024) # buffer size is 1024 bytes
    print "received message:", data

    if len(data) < 2:
        print "Invalid data:", data
        continue

    trainId = int(data[0])
    value = int(data[1:])

    if value > 100:
        value = 100
    elif value < -100:
        value = -100

    if trainId == 1:
        if value > 0:
            p2.ChangeDutyCycle(0)
            p.ChangeDutyCycle(value)
        elif value < 0:
            p.ChangeDutyCycle(0)
            p2.ChangeDutyCycle(-value)
        else:
            p.ChangeDutyCycle(0)
            p2.ChangeDutyCycle(0)
    elif trainId == 2:
        if value > 0:
            p3.ChangeDutyCycle(0)
            p4.ChangeDutyCycle(value)
        elif value < 0:
            p4.ChangeDutyCycle(0)
            p3.ChangeDutyCycle(-value)
        else:
            p3.ChangeDutyCycle(0)
            p4.ChangeDutyCycle(0)


p.stop()
p2.stop()
p3.stop()
p4.stop()
GPIO.cleanup()

