#!/usr/bin/python
# -*- coding: utf-8 -*-

import subprocess
import time

"""
 
[+] socat <option>      받는쪽            보낼쪽
 -  socat -d -d -d tcp-l:portnum tcp:target-ip:portnum

[+] fork옵션: tcp-l 에 fork 옵션을 주면 client에서 접속을 끊어도 계속 살아있다.   
    (listening상태) 일명 "daemon mode" 라고 한다.
 -  socat tcp-l:portnum,fork tcp:target-ip:portnum

가상 네트워크 인터페이스
비슷한 방법으로 tun/tap 장비들과 같은 가상 네트워크 쌍을 만들 수 있습니다. 
(다시 말하지만 메인프로세스 - socat - 이 살아있는 동안에만 네트워크 쌍이 존재합니다.)

sudo socat -d -d tun:10.0.0.1/8 tun:192.168.0.1/24
네, 이겁니다. 이제 가상 네트워크 인터페이스가 생겼네요

nohup socat -lm UDP4-RECVFROM:9111,fork UDP4-SENDTO:10.192.1.1:9111 2>&1 &

""" 


class PyVSP(object):
     
    def __init__(self, link1="./ttyVSP1", link2="./ttyVSP2"):
        super(PyVSP, self).__init__()
        args = ["socat", "pty,raw,echo=0,link="+link1, "pty,raw,echo=0,link="+link2]
        self.p = subprocess.Popen(args)
        self.vsp1 = link1
        self.vsp2 = link2
        time.sleep(1)
 
    def stop(self):
        self.p.terminate()
 
    def __del__(self):
        self.stop()

# filename: pyvsp_test.py
 
import unittest
import serial
 
class PyVspTestCase(unittest.TestCase):
 
    @classmethod
    def setUpClass(cls):
        cls.pv = PyVSP("vsp1", "vsp2"); #현재 폴더에 vsp1, vsp2 라는 이름으로 심볼릭 링크를 생성함.
        return
 
    @classmethod
    def tearDownClass(cls):
        cls.pv.stop()
        return
 
    def runTest(self):
        sender   = serial.Serial(self.pv.vsp1)
        receiver = serial.Serial(self.pv.vsp2)
 
        send_msg = "Hello\n"
        sender.write(send_msg)
 
        read_msg = receiver.readline()
 
        self.assertEqual(read_msg, send_msg)
        print "send_msg: %s" % send_msg
        print "read_msg: %s" % read_msg 
 
if __name__ == '__main__':
    unittest.main()