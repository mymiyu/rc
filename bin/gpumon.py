#!/usr/bin/env python3

'''
GPU monitoring script
@author Do-Won Nam
'''

import os
import sys
import subprocess

servers = {
    '1'    : 'apldev1',
    '2'    : 'apldev2',
    '3'    : 'apldev3',
    '4'    : 'apldev4',
    '5'    : 'apldev5',
    '6'    : 'apldev6',
    '7'    : 'apldev7',
    '8'    : 'apldev8',
    '9'    : 'apldev9'}

myhost = 'localhost'

def do_gpustat(svr_addr):
    if (svr_addr == myhost):
        shellcmd = "gpustat.py -u"
    else:
        shellcmd = "ssh " + svr_addr + " gpustat.py -u"
    os.system(shellcmd)

def main_loop():
    if (num_args == 0):
        svr = myhost
        do_gpustat(svr)
    elif (sys.argv[1] == 'all'):
        for svr in servers.keys():
            do_gpustat(servers[svr])
            print('')
    else:
        do_gpustat(servers[sys.argv[1]])

if __name__ == '__main__':
    num_args = len(sys.argv) - 1
    if (num_args != 0 and (sys.argv[1] not in servers.keys() and sys.argv[1] != 'all')):
#        print("Usage: " + sys.argv[0] + " [ all | 1 | 2 | 3 | 4 | 5 | 6 ]")
        print("Usage: " + sys.argv[0] + " [ all | 2 | 3 | 4 | 5 | 6 | 7 ]")
        sys.exit()

    myhost = subprocess.check_output('hostname')
    while True:
        main_loop()

        keyin = input('\nPRESS \'q\' to STOP, \'c\' to CLEAR SCREEN : ')
        if (keyin == 'c'):
            os.system("clear")
        elif (keyin == 'q'):
            break
        else:
            continue
