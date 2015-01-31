#!/usr/bin/env python
# -*- coding: utf-8 -*-

################################################################################
#
#   unix tail -f 파이썬 구현 3
#        내가 원하는 linux 엔지니어적인 방법
#       select, supprocess, pipe 이용 => 범용 해결책 :: 내가 찾던 답이다.
#
################################################################################

import select
import subprocess
       

def watcher(cmd, callback):
    import platform  
    
    if platform.system() == 'Windows':
        raise RuntimeError("\n## Error:: [only Linux/Unix command(tail -f, top ...) support] ##")
        
    # cmd = 'tail -f %s' % file  
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
    
    #proc = subprocess.Popen('tail -f ./random_text.log', shell=True, bufsize=1, stdout=subprocess.PIPE, stderr=`.STDOUT)
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

    
if __name__ == "__main__":

    import platform, sys, signal
    import datetime
    from threading import Thread
    from multiprocessing import Process
    
    import subprocess
    import json
    
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

    import httplib, urllib, urllib2
    import tornado
    import traceback
    
    def callback(line):
        date = datetime.datetime.today()
        print 'Line[%s]: "%s"' % (date, line)
       
        url  =  "http://211.224.204.153:18003/log"
        data = {"log": line }
        body = urllib.urlencode(data)
        #print body
        
        try:
            # LJG: 보안이슈로 POST사용
            req = urllib2.Request(url, body)
            response = urllib2.urlopen(req)
            the_page = response.read()
            print "response:: ", the_page     
                                
        except:
            errmsg = "Error:: \n<<%s>>" % (traceback.format_exc() )            
            print (errmsg)
        
        
    """
    #
    # 로그파일 발생기
    
    # Thread shows performance degrade by 15% compared to Process
    # Thread(target=random_write, args=()).start()
    
    
    #Process(target=random_write, args=(10000,)).start()
    
    # 
    # tail -f 파이썬 구현1 테스트(합격)    
    
    
    # tail('./random_text.log', callback).mainloop(sleepfor=0.1)

    #
    # tail -f 파이썬 구현2 테스트(불합격)
    file = './random_text.log'    
    loglines = follow2(file)
    #for line in loglines: print "## %s" % line
    """
     
    
    cmd = "tail -f /var/log/rsyslog/all_host_openstack.log"
    watcher(cmd , callback)