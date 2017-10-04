from RPIO import PWM

GPIO = 4
GPIO2 = 3

servo = PWM.Servo()

# Set servo on GPIO to 1200us (1.2ms
servo.set_servo(GPIO, 2000)

raw_input('Enter your input:')

servo.stop_servo(GPIO)
servo.set_servo(GPIO2, 1000)

raw_input('Enter your input:')

# Set servo on GPIO17 to 2000us (2.0ms
servo.set_servo(GPIO, 2000)

raw_input('Enter your input:')

# Clear servo on GPIO17
servo.stop_servo(GPIO)
