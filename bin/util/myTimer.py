#!/usr/bin/env python
# -*- coding: utf-8 -*-

from threading import Thread, Timer

class MyTimer(object):
    """
    일정 주기로 동작을 수행하는 클래스
    동작을 수행할 때 마다 새로운 쓰레드를 만들어서 수행하므로 
    쓰레드 생성 및 정리 부하가 있다
    """

    maxnum = 0
    curnum = 0

    def __init__(self, interval, function, *args, **kwargs):
        self._timer = None
        self.interval = interval
        self.function = function
        self.args = args
        self.kwargs = kwargs
        self.is_running = False
        # self.start()

    def check(self):
        self.curnum += 1
        
        # 0이면 무한루프
        if self.maxnum == 0:
            return True
        
        if self.curnum > self.maxnum:
            self.curnum = 0
            return False
        
        return True

    def _run(self):
        """
            notice!!!
              함수를 호출하는 순서가 중요
            
            case1) 
                function()
                start()
            case2) 
                start()
                function()
            
            case1) 
                동작: sequential loop 실행
                장점: sequential 하게 동작하므로 쓰레드 safe하다
                단점: function()수행시간이 길어지면 의도했던 간격으로 동작하지 않고 실행시간이 계속 밀린다.
            case2) 
                동작: 쓰레드가 정확한 간격으로 루프 실행, 동시에 여러개의 쓰레드 실행가능
                장점: 정확한 간격의 시간에 개별 쓰레드를 실행하여 동작하므로 의도했던 시간간격에 정확히 작업이 진행된다.
                단점: function()수행이 길고 간격이 짧으면 function()수행이 다중쓰레드 환경에 노출되므로
                   thread safe하지 않아서 쓰레드간의 공유리소스가 있으면 충돌에러가 발생한다.            
        """       
        self.is_running = False
        self.function(*self.args, **self.kwargs)
        self.start()

    def start(self):
        if not self.check():
            self.stop()
            return 
        if not self.is_running:
            self._timer = Timer(self.interval, self._run)
            self._timer.start()
            self.is_running = True

    def stop(self):
        self._timer.cancel()
        self.is_running = False

class ReentrantTimer(object):
    """
    A timer that can be restarted, unlike threading.Timer
    (although this uses threading.Timer)

    t: timer interval in milliseconds
    fn: a callable to invoke
    """
    def __init__(self, t, fn):
        self.timer = None
        self.t = t
        self.fn = fn

    def start(self):
        if self.timer is not None:
            self.timer.cancel()

        self.timer = Timer(self.t / 1000., self.fn)
        self.timer.start()

    def stop(self):
        self.timer.cancel()
        self.timer = None
        
if __name__ == '__main__':

    _cnt = 1    
    def callbackByTimer(msg, *args, **kwargs):
        global _cnt
        
        import threading
        from datetime import datetime
                
        th = threading.currentThread()
        
        print "%d] %s" % (_cnt, msg)
        _cnt += 1
        print "    time :: ", str(datetime.now())
        print "    thread info -> ", th
        print "    thread id   -> ", id(th)              
        
    mt = MyTimer(1, callbackByTimer, 'jingooTimer')
    mt.start()

