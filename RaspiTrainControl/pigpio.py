#!/usr/bin/env python

import time, sys, random

import pigpio

pi = pigpio.pi() # connect to local Pi

start_time = time.time()

while (time.time()-start_time) < 60: 
   R = random.randrange(0, 255, 1)
   G = random.randrange(0, 255, 1)
   B = random.randrange(0, 255, 1)

   pi.set_PWM_dutycycle(2, R)
   pi.set_PWM_dutycycle(3, B)
   pi.set_PWM_dutycycle(14, G)

   time.sleep(2)

pi.stop()

