import RPIO

print "This line will be printed."

RPIO.setup(4, RPIO.OUT)

RPIO.output(4, True)
