Lockpick Box
======

The DCDN lockpick boxes are beautiful wooden boxes with a variety of locks, by:
- blak_hal0 (box construction, lock set-up and pinning)
- bunni, kris@kbembedded.com (electronics and firmware)

Overview
======

The box contains a total of 8 locks of varying difficulty, scale from 1 to 10:
- Outside padlock, 1
- Wafer locks (left side)
-- Bottom, two wafer, 3
-- Middle, three wafer, 3
-- Top, five wafer, 5
- Tumbler locks (bottom side)
-- Left, three pin, 6
-- Middle, five pin, 8
-- Right, five pin + security pin, 10
- Inside padlock, 7

Once the outside lock is unlocked and the box is opened, the firmware starts
the timer and displays a few messages to the player.  While the box firmware
is running, a 16 digit code is displayed, this is a ciphertext that encodes
data about the current session.  See "Operation Details" below for more info.

The lid is monitored with a reed switch in the body and a magnet inserted in 
the rim of the lid.  A bottom access panel exists that uses a magnetic
child-proof latch.  Holding a magnet on the bottom of the box ~2 in from the 
front of the box in the center will unlatch it and provide access to the 
internals of the box.


All of the files contained in this repo are for the electronics and firmware

src-prop/
- Contains the firmware running on the Propeller
eagle/
- Contains EagleCAD board files and gerbers


Operation Details
======

Locks
======

The outer padlock has no electrical connection.  The lock is considered opened
when the box is opened.

The inner padlock holds in place a metal latch that is preventing the actuation
of a toggle switch.  This lock is considered opened when the switch is thrown.

The 6 cylinder locks are each connected to their own IO pin of the uC.  Each 
lock has a cam at the rear of the lock that when spun will eventually contact
a post.  Each post is also wired to its own IO pin on the uC.  This setup
is simple, but has drawbacks:
- Noise.  Even with proper pullups, the locks or posts (acting as exposed IO
  pins) are heavily susceptible to noise, and therefore false triggering.

The drawback above, cimbined with the difficulty of wiring directly to 
the moving cams makes a common voltage bus setup very difficult to reliably do.

The solution for this was to generate a waveform on the locks, and watch for
it to be fed back on the posts.  As soon as a lock is opened, the driven
waveform is disabled to prevent jumping.  


Firmware
======

The brains of the box are a Parallax Propeller uC.  The Prop provides four
main functions:
- Drive HD44780 2x16 display.
- Drive and poll the locks
- Generate TEA ciphertext/CRC8
- Communicate with EEPROM to load/store sequence number


Ciphertext
======

The ciphertext output is a 16 digit hex number that encodes the following 
information:
- Box ID (0x0 through 0xF) bits 63:60
- Sequence number (0x0 through 0xFFFFFFF, 0 through 268,435,455) bits 59:32
- Locks open (8bit value, one bit per lock) bits 31:24
- Time passed since box opened (16bits, 100 ms resolution, ~1 hr 49 min) bits 23:8
- CRC8 of upper 7 bytes, bits 7:0


Bugs
======

- Switch LED doesn't light up because I changed the input from a pulldown 
    to a pullup on the new PCB.


TODO
======

- Make some changes to the schematic
-- Add ground pin where NC pin is. 
-- Repurpose extra lock/post pin as buzzer and add ground hole

