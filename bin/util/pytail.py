#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""LJG :: 파이썬으로 만든 tail -f(3가지 버전)  

module    : pytail
make      : 2013.06.09
version   : 0.7
작성동기   : 
    파이썬에서 interactive 하게 유닉스의 다양한 명령을 실행하고 
    그 결과를 활용할 수 있는지를 알아보고자 함이었다.

    활용케이스 1]
        단순 유닉스 명령을 실행하고 결과를 받는예
        ex) ps -ef

        def run_cmd(command='ps -ef'):    
            proc = subprocess.Popen(command,shell=True,
                                    stdout=subprocess.PIPE,
                                    stderr=subprocess.PIPE)
            (res, err) = proc.communicate()            
            if err != '':
                raise RuntimeError("[%s] command Error \n[%s]" % (command, err))
            else:
                return res
        
    활용케이스 2] 
        -> 이 경우는 아래 3번 구현방법으로 해결(결과는 단순했지만 그 방법은 찾는 것은 힘들었슴)
        interactive action을 수행하는 경우
        ex) tail -f /var/log
        
        def run_interactive_cmd(cmd, callback):
            proc = subprocess.Popen(cmd, 
                            shell=True, 
                            bufsize=1, 
                            stdout=subprocess.PIPE, 
                            stderr=subprocess.STDOUT)
            while True:
                (rlist, wlist, xlist) = select.select([proc.stdout], [], [], 1)
                if proc.stdout in rlist:
                    line = proc.stdout.readline()
                    #print "read :", line
                    if callback:
                        callback(line)
                        
                if proc.poll() is not None:
                    raise RuntimeError("process died. Aborting.")        
 
"""

################################################################################
#
#   unix tail -f 파이썬 구현 1
#   가장 안정적이고 전통파적인 방법 : 
#
################################################################################

'''A module which implements a unix-like "tail" of a file.
A callback is made for every new line found in the file.  Options
specify whether the existing contents of the file should be read
or ignored.

@author Sean Reifschneider <jafo@tummy.com>
@version $Revision: 1.52 $

Released under the GPLv2 or any later version.

If a file is emptied or removed, the tail will continue reading lines
which are written in the new place.

Simple example:

    import tail

    def callback(line):
        print 'Line: "%s"' % string.rstrip(line)

    tail.tail('/var/log/all', callback).mainloop()
'''

import time
import string
import os

class tail:
    def __init__(self, filename, callback, tailbytes = 0):
        '''Create a new tail instance.
        Create a tail object which periodicly polls the specified file looking
        for new data which was written.  The callback routine is called for each
        new line found in the file.

        @return Nothing
        @param filename File to read.
        @param callback Function which takes one argument, called with each
                line read from the file.
        @param tailbytes Specifies bytes from end of file to start reading
                (defaults to 0, meaning skip entire file, -1 means read full file).
        '''
        self.skip = tailbytes
        self.filename = filename
        self.callback = callback
        self.fp = None
        self.lastSize = 0
        self.lastInode = -1
        self.data = ''

    def process(self):
        '''Examine file looking for new lines.
        When called, this function will process all lines in the file being
        tailed, detect the original file being renamed or reopened, etc...
        This should be called periodicly to look for activity on the file.

        @return Nothing
        '''
        #  open file if it's not already open
        if not self.fp:
            try:
                self.fp = open(self.filename, 'r')
                stat = os.stat(self.filename)
                self.lastIno = stat[1]
                if self.skip >= 0 and stat[6] > self.skip:
                    self.fp.seek(0 - (self.skip), 2)
                self.skip = -1
                self.lastSize = 0
            except:
                if self.fp: self.fp.close()
                self.skip = -1    #  if the file doesn't exist, we don't skip
                self.fp = None
        if not self.fp: return

        #  check to see if file has moved under us
        try:
            stat = os.stat(self.filename)
            thisSize = stat[6]
            thisIno = stat[1]
            if thisSize < self.lastSize or thisIno != self.lastIno:
                raise Exception
        except:
            self.fp.close()
            self.fp = None
            self.data = ''
            return

        #  read if size has changed
        if self.lastSize < thisSize:
            while 1:
                thisData = self.fp.read(4096)
                if len(thisData) < 1:
                    break
                self.data = self.data + thisData

                #  process lines within the data
                while 1:
                    pos = string.find(self.data, '\n')
                    if pos < 0: break
                    line = self.data[:pos]
                    self.data = self.data[pos + 1:]
                    
                    #  line is line read from file
                    if self.callback: self.callback(line)

        self.lastSize = thisSize
        self.lastIno = thisIno

    def mainloop(self, sleepfor = 0.5):
        '''Loop forever processing activity on the tail object.
        This routine is intended to be called in programs which do not need
        to do other processing.  This routine never returns.

        @return Never returns
        @param sleepfor Seconds between processing (default is 5 seconds).
        '''
        while 1:
            self.process()
            time.sleep(sleepfor)


################################################################################
#
#   unix tail -f 파이썬 구현 2
#       coroutine 이용 : 속도가 빨라질까? => 정확하지 않슴(단지, 코루틴만 배우자)
#       
#       file = './random_text.log'    
#       for line in follow(file):
#           print "## %s" % line
################################################################################
"""
단점 :: 아래처럼 file write 속도가 빠르면 tail -f가 정확하게 이루어지지 않고 
        건너띄는 현상 발생: 8 라인이 파일에 써 졌는데 3개만 tail 해줌.
### start random_write
  1] 2013-06-07 01:37:08.704741]  65] t0aiWmIfUDGhACQomqkdYBrWyTXogwNgCmCOGW0NBljYV26cnKfPxfE2NSdr0k4cP
  2] 2013-06-07 01:37:09.625969]  68] 2Lsf6EIECNlnx6M6LZQwMINTnaJExgbFmJ9Y58zMqFyAveQjOZiXGoSkqFneXG1KaVbT
  3] 2013-06-07 01:37:10.607193]  60] oslfS6eOTZ7CuLnnDuXF6ByMWDicm2tk6mURmHNKck1FM2cU3SYw8l22JebT
  4] 2013-06-07 01:37:10.707528]  74] qpa9mULzQwbJ9DURVU8l2xRcwwEvd0vm9cO9GjQbXkpGNeiqLBKHyEhgPzpysnbU4yA8SOOgWp
##   4] 2013-06-07 01:37:10.707528]  74] qpa9mULzQwbJ9DURVU8l2xRcwwEvd0vm9cO9GjQbXkpGNeiqLBKHyEhgPzpysnbU4yA8SOOgWp

  5] 2013-06-07 01:37:11.418452]  63] dgE3qHdVcTqK4uEMAfNB1rNuF0E89ETqUSOg2wbtUdNRu05DLNiFCeLxrjFjsjx
  6] 2013-06-07 01:37:12.359632]  76] 3G85AE6TgkL2vxFbwRZPG5cvkSQdsbvieU9DVfs4M55s1xP5cSRumIBU3mAaTaCQ9fRUgPjDQi0F
##   6] 2013-06-07 01:37:12.359632]  76] 3G85AE6TgkL2vxFbwRZPG5cvkSQdsbvieU9DVfs4M55s1xP5cSRumIBU3mAaTaCQ9fRUgPjDQi0F

  7] 2013-06-07 01:37:13.280837]  77] dOUqssQpf6WKh4u6Y7PdrINjOkhhXf6G8T7vWOX9vqqfwYXKiobjiPSVWcoAgMhgCNt9ygve0SlEW
  8] 2013-06-07 01:37:13.611405]  69] H1Q8ImfFvmvy6ueab1JZcGxPCD1o1GcHzhSPdNtyO0zhilK7hxkMz7I8j3cQnq6UIbmdE
##   8] 2013-06-07 01:37:13.611405]  69] H1Q8ImfFvmvy6ueab1JZcGxPCD1o1GcHzhSPdNtyO0zhilK7hxkMz7I8j3cQnq6UIbmdE


"""
def follow1(filepath):
    print "filepath: " , filepath 
    thefile = open(filepath, "r")
    thefile.seek(0,2)
    while True:
        line = thefile.readline()
        # print "line: [%s]" % line
        if line:
            yield line
            
        thefile.close()
        thefile = open(filepath, "r")
        thefile.seek(0,2)

def follow2(filepath):
    while True:
        with open(filepath) as f:
            f.seek(0,2)
            line = f.readline()
            if line:
                yield line        


################################################################################
#
#   unix tail -f 파이썬 구현 3
#        내가 원하는 linux 엔지니어적인 방법
#       select, supprocess, pipe 이용 => 범용 해결책 :: 내가 찾던 답이다.
#
################################################################################

import select
import shlex
import subprocess

def run_cmd(command='ps -ef'):
    
    print command
    
    proc = subprocess.Popen(command,shell=True,
                            stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    (res, err) = proc.communicate()
    
    if err != '':
        raise RuntimeError("[%s] command Error \n[%s]" % (command, err))
    else:
        return res
        
def tail_simul(file, callback):
    import platform
    
    if platform.system() == 'Windows':
        raise RuntimeError("\n## Error:: [only Linux/Unix command(tail -f, top ...) support] ##")
        
    cmd = 'tail -f %s' % file  
    # cmd = 'top -c -b'  # => 화면 사이즈에 의해 내용이 잘림. TERM 설정에서 화면 출력 사이즈를 키울수 없나?
    
    """
    원본::
    778 root      20   0 22808 4052 1700 S    0  0.0   0:00.15 -bash
    813 root      20   0  7264  292  200 S    0  0.0   0:00.00 dhclient3 -e IF_METRIC=100 -pf /var/run/dhclient.eth0.pid -lf /var/lib/dhcp/dhclient.eth0.le
    835 root      20   0 49956  368  252 S    0  0.0   0:00.17 /usr/sbin/sshd -D

    이 프로그램으로 캡쳐한 결과:: 813 프로세스의 command line이 확실히 잘려있다.(수집이 80컬럼까지만 됨)
    778 root      20   0 22808 4052 1700 S    0  0.0   0:00.15 -bash
    813 root      20   0  7264  292  200 S    0  0.0   0:00.00 dhclient3 -e IF_MET
    835 root      20   0 49956  368  252 S    0  0.0   0:00.17 /usr/sbin/sshd -D
    """
    print cmd
    
    #proc = subprocess.Popen('tail -f ./random_text.log', shell=True, bufsize=1, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    proc = subprocess.Popen(cmd, shell=True, bufsize=1, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    while True:
        (rlist, wlist, xlist) = select.select([proc.stdout], [], [], 1)
        if proc.stdout in rlist:
            line = proc.stdout.readline()
            #print "read :", line
            if callback:
                callback(line)
                
        if proc.poll() is not None:
            raise RuntimeError("process died. Aborting.")

            
################################################################################
#
#   파이썬으로 구현한 tail -f 프로그램을 테스트 하기 위해
#   임의의 텍스트라인을 임의의 시간주기로 파일에 기록하는 라이브러리
#
################################################################################

import random

def get_random_word(wordLen):
    word = ''
    for i in range(wordLen):
        word += random.choice('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789')
    return word
    
def random_write(num):
   
    import sys,os,stat,time, datetime
    import random
    
    print datetime.datetime.today()
    print "### start random_write"       
    
    bufsize = 1024
    fout = open('./random_text.log', 'w', bufsize)
    for i in range(num):
        wordLen = random.randint(60, 80)           
        word = get_random_word(wordLen)
        i += 1
        date = datetime.datetime.today()
        line = "%3d] %s] %3d] %s" % (i, date, len(word), word)
        print line
        
        if i % 10 == 0:
            fout.close()
            fout = open('./random_text.log', 'a', bufsize)
            
            print i
        
        fout.write(line+"\n")
        fout.flush()
        
        idx = random.randint(10,100)        
        time.sleep(0.001 * idx)
                
    fout.close()
    print "MY JOB DONE!!!"
    sys.exit(1)
    
################################################################################
    
if __name__ == "__main__":

    import platform, sys, signal
    if platform.system() == 'Windows':
        pass
    else:      
        def signal_handler(signal, frame):
            print 'You pressed Ctrl+C!'
            sys.exit(0)                   
        # Ctrl+Z는 프로세스가 정상적으로 죽지않으므로 무시하도록 한다        
        signal.signal(signal.SIGTSTP, signal.SIG_IGN)
        signal.signal(signal.SIGINT, signal_handler)
        print 'Press Ctrl+C to kill'
        # signal.pause()
    
    #
    # 로그파일 발생기
    from threading import Thread
    # Thread shows performance degrade by 15% compared to Process
    # Thread(target=random_write, args=()).start()
    
    from multiprocessing import Process
    #Process(target=random_write, args=(10000,)).start()
    
    # 
    # tail -f 파이썬 구현1 테스트(합격)
    import datetime
    
    def callback(line):
        date = datetime.datetime.today()
        print 'Line[%s]: "%s"' % (date, line)

    # tail('./random_text.log', callback).mainloop(sleepfor=0.1)

    #
    # tail -f 파이썬 구현2 테스트(불합격)
    file = './random_text.log'    
    loglines = follow2(file)
    #for line in loglines: print "## %s" % line
        
    #
    # tail -f 파이썬 구현3 테스트(합격)
    # 내가 찾던 답
    tail_simul(file, callback)
    