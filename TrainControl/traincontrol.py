import socket
from RPIO import PWM

GPIO11 = 2
GPIO12 = 3

GPIO21 = 2 # todo
GPIO22 = 3 # todo

servo = PWM.Servo()

servo.set_servo(GPIO11, 0)
servo.set_servo(GPIO12, 0)

servo.set_servo(GPIO21, 0)
servo.set_servo(GPIO22, 0)

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

    if value > 19990:
        value = 19990
    elif value < -19990:
        value = -19990

    if trainId == 1:
        if value > 0:
            servo.stop_servo(GPIO12)
            servo.set_servo(GPIO11, value)
        elif value < 0:
            servo.stop_servo(GPIO11)
            servo.set_servo(GPIO12, -value)
        else:
            servo.stop_servo(GPIO11)
            servo.stop_servo(GPIO12)
    elif trainId == 2:
        if value > 0:
            servo.stop_servo(GPIO22)
            servo.set_servo(GPIO21, value)
        elif value < 0:
            servo.stop_servo(GPIO21)
            servo.set_servo(GPIO22, -value)
        else:
            servo.stop_servo(GPIO21)
            servo.stop_servo(GPIO22)


servo.stop_servo(GPIO11)
servo.stop_servo(GPIO12)
servo.stop_servo(GPIO21)
servo.stop_servo(GPIO22)
