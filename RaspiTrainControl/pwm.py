import RPIO.PWM as PWM

GPIO = 2
CHANNEL = 0
GPIO2 = 3
CHANNEL2 = 3

PWM.set_loglevel(PWM.LOG_LEVEL_DEBUG)

PWM.setup()
PWM.init_channel(CHANNEL)
PWM.print_channel(CHANNEL)

PWM.add_channel_pulse(CHANNEL, GPIO, 0, 500)

raw_input('Enter your input:')

PWM.init_channel(CHANNEL2)
PWM.print_channel(CHANNEL2)

PWM.add_channel_pulse(CHANNEL2, GPIO2, 600, 200)

raw_input('Enter your input:')

PWM.clear_channel(CHANNEL)

raw_input('Enter your input:')

PWM.clear_channel(CHANNEL2)

raw_input('Enter your input:')

PWM.add_channel_pulse(CHANNEL, GPIO, 0, 200)

raw_input('Enter your input:')

PWM.cleanup()
