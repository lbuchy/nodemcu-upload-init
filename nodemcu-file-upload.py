#!/usr/bin/env python2.7

import argparse
import serial
import time

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description = 'nodemcu init.lua uploader', prog = 'nodemcu-init-uploader')

    parser.add_argument(
            '--port', '-p',
            help = 'Serial port device',
            default = '/dev/ttyUSB0')

    parser.add_argument(
            '--baud', '-b',
            help = 'Serial port baud rate',
            default = 9600)

    parser.add_argument(
            '--file', '-f',
            help = 'init.lua file',
            default = 'init.lua')

    args = parser.parse_args()

    port = serial.Serial(args.port, args.baud)

    # Open a file on the nodemcu
    port.write("file.open(\"" + "init.lua" + "\", \"w\")\n")

    time.sleep(1)
    script = file(args.file, 'r')

    buf = ""
    for line in script:
        upload_line = "file.writeline([[" + line.rstrip() + "]])\n"
        port.write(upload_line)
        print(upload_line)
        time.sleep(0.5)
    port.write("file.close()\n")
    time.sleep(1)

    port.close()
    script.close()

    # Add a 
