#!/usr/bin/env python
# -*- coding: utf-8 -*-
    
import sys
import pexpect
import getpass, os
import time

class MyError(Exception): pass

class myRSSH():
    """
        pexpect를 이용한 간단한 remote ssh 활용 클래스
        나중에 시간되면 pxssh로 대체할 예정.
        
        ####################################################################################
        사용예:: 나의 사견임
            case1] 명령결과를 받아서 처리할 때 
                -> ssh_command()를 사용하면 결과만 리턴되고 그 결과를 파싱만하는구조로 코딩이 쉽다
                그러나, 명령을 많이 주고 받는다면 통신관점에서는 비효율적이고
                과하게 사용하면 부하를 줄수도 있다. 주기적인 "ps -ef rssh"로 상태모니터링 필요
            case2] 결과를 받아서 처리할 필요가 없는 배치성 작업에 유용 
                -> 한번 로그인 하고 "sendline() -> expect() -> process()" 흐름이 반복되는 배치작업에 적합
                만약, 결과를 받아 처리해야 하는 경우에는 
                expect에 예상되는 응답 패턴을 일일이 만들어 주어 원하는 결과값만 추출하는 전처리 과정이 필요
            참고] 코딩시에는 나의 출력문을 모두 막고 debug mode만으로 상태를 점검하라.!!!!
        ####################################################################################
        command = 'df -h'
        case1]
            rssh = myRSSH()
            #rssh.debug = True
            child = rssh.command (host, id, pw, cmd, port)
            idx = child.expect([pexpect.TIMEOUT, pexpect.EOF])
            
            #응답셈플
            ##################################################################
            host: 14.63.160.92/11101 user: rdbaas: cmd: sudo df -h =>
            ##################################################################
            Filesystem            Size  Used Avail Use% Mounted on
            /dev/mapper/VolGroup00-LogVol00
                                   18G  3.4G   14G  21% /
            /dev/xvda1             99M   14M   80M  15% /boot
            tmpfs                 1.0G     0  1.0G   0% /dev/shm
            /dev/xvdb1             79G  4.2G   71G   6% /rdbaas-data
            ##################################################################
        case2]
            rssh = myRSSH()
            rssh.debug = True
            child = rssh.login(host, id, pw, port)
            child.sendline(cmd)        
            # 이렇게 패턴을 만들어야 하고 리턴값에서 군더더기를 잘라내야 한다.
            idx = child.expect([pexpect.TIMEOUT, pexpect.EOF, 'rdbaas-data'])
            
            #응답셈플
            ##################################################################
            host: 14.63.160.92/11101 user: rdbaas: cmd: sudo df -h =>
            ##################################################################
            Last login: Thu Feb 14 09:55:12 2013 from 14.63.254.11
            sudo df -h
            [rdbaas@4857a623-e81a-486c-9b05-2aff73cf2190 ~]$ sudo df -h
            Filesystem            Size  Used Avail Use% Mounted on
            /dev/mapper/VolGroup00-LogVol00
                                   18G  3.4G   14G  21% /
            /dev/xvda1             99M   14M   80M  15% /boot
            tmpfs                 1.0G     0  1.0G   0% /dev/shm
            /dev/xvdb1             79G  4.2G   71G   6% /rdbaas-data
            ##################################################################
    """
    
    COMMAND_PROMPT = '[$#] '
    TERMINAL_PROMPT = r'Terminal type\?'
    TERMINAL_TYPE = 'vt100'
    SSH_NEWKEY = r'Are you sure you want to continue connecting \(yes/no\)\?'


    def __init__(self):
        self.debug      = False     # remote ssh stdin/out display to console
        self.fdebug     = True      # remote ssh stdin/out display to file
        self.timeout    = 5        # remote ssh command timeout
        self.servinfo   = {}
    
    def register(self, name, ip, port, id, pw):
        self.servinfo[name] = (ip, port, id, pw)
    
    def serv_keys(self):
        return self.servinfo.keys()
    
    def getservinfo(self, name):
        if self.servinfo[name]:
            return self.servinfo[name]
        else:
            errmsg = "name[%s] does not exists!! registger first!!" % (name)
            print errmsg
            raise RuntimeError(errmsg)

    def pexpect_info(self, child):
        cnt = 0
        print "#"*80
        print " PEXPECT Child Instance Info"
        print "#"*80
        for line in str(child).splitlines():
            cnt = cnt + 1
            print "    %4s ::  %s" % (cnt, line)
        
        print "#"*80    
    # ------------------------------------------------------------------------------
    
    # --------------------------------------------------------------------------
    def delegate (self, pw, mode, cmd):
    
        """
        This runs a command on the remote host. This could also be done with the
        pxssh class, but this demonstrates what that class does at a simpler level.
        This returns a pexpect.spawn object. This handles the case when you try to
        connect to a new host and ssh asks you if you want to accept the public key
        fingerprint and continue connecting. 
        """
        #print "cmd: [%s]" % cmd
        
        ssh_newkey = 'Are you sure you want to continue connecting'
        child = pexpect.spawn(cmd, timeout=self.timeout)
        # pexpect_info(child)
    
        if self.debug:
            child.logfile_read = sys.stdout
            child.logfile_send = sys.stdout
        
        if self.fdebug:    
            fout = file ("./rssh.log","a+")
            child.logfile = fout
        
        try:
            i = child.expect([pexpect.TIMEOUT, ssh_newkey, 'password: '], timeout=self.timeout)
            
            if i == 0: # Timeout
                errmsg = "ERROR :: Connection Timeout [%s, %s]" % (child.before, child.after)
                raise MyError(errmsg)
            
            elif i == 1: # SSH does not have the public key. Just accept it.
                
                child.sendline ('yes')
                
                i = child.expect([pexpect.TIMEOUT, 'password: '], timeout=self.timeout)
                
                if i == 0: # Timeout
                    errmsg = "ERROR :: Login Timeout [%s, %s]" % (child.before, child.after)
                    raise MyError(errmsg)
                
                elif i == 1: #
                    child.sendline(pw)
                    
            elif i == 2:
                child.sendline(pw)

        except Exception, e:
            child.close()
            errmsg = str(e)
            raise MyError(errmsg)
            
        if child == None:
            child.close()
            errmsg = "ERROR :: pexpect is null [%s, %s]" % (child.before, child.after)
            raise MyError(errmsg)
    
        if mode == 'RemoteShell':
            return child
        else:
            child.expect(pexpect.EOF)
            result = child.before
            child.close()
            return result.strip()

    # --------------------------------------------------------------------------
    def getRemoteShell(self, name):
        """ 
        get remote-shell & later, will do interactive commands 
        user should close child resource by youself after use!!!
        
        interactive mode 로 사용할 때는 사용자가 정확히 어떤 패턴의 결과가
        나올지를 예상하고 그에따라 일일이 코딩해 주어야 한다는 단점이 있다.
        
        사용예]
        
            child.sendline('ps aux | grep topmon-clnt | grep -v grep')
            
            #
            # 이렇게 맨끝에 얻기를 원하는 패턴(rdbaas-data)을 만들어야 하고 
            # 리턴값에서 필요한 값을 추출해 사용해야 한다
            # timeout을 적당히 설정해서 실패시 신속한 응답을 받을수 있도록 한다.
            idx = child.expect([pexpect.TIMEOUT, pexpect.EOF, 'rdbaas-data'], timeout=3)
            
            응답셈플
                ##################################################################
                host: 14.63.160.92/11101 user: rdbaas: cmd: sudo df -h =>
                ##################################################################
                Last login: Thu Feb 14 09:55:12 2013 from 14.63.254.11
                sudo df -h
                [rdbaas@4857a623-e81a-486c-9b05-2aff73cf2190 ~]$ sudo df -h
                Filesystem            Size  Used Avail Use% Mounted on
                /dev/mapper/VolGroup00-LogVol00
                                       18G  3.4G   14G  21% /
                /dev/xvda1             99M   14M   80M  15% /boot
                tmpfs                 1.0G     0  1.0G   0% /dev/shm
                /dev/xvdb1             79G  4.2G   71G   6% /rdbaas-data
                ##################################################################
                        
            if idx == 0:
                # 원하는 응답이 안온경우
                print "TimeOut:: ", rssh.timeout
            elif idx == 1:
                print "EOF"
            else:
                # 원하는 응답을 발견한 경우
                print "FIND"
                
            result = child.before
        
        """
        
        ip, port, id, pw = self.getservinfo(name)

        cmd = 'ssh -p %s %s@%s'%(port, id, ip)
        mode = 'RemoteShell'
        return self.delegate(pw, mode, cmd)        

    # --------------------------------------------------------------------------
    def doRemoteCommand(self, name, command):
        """ do remote ssh command once """
        ip, port, id, pw = self.getservinfo(name)

        cmd = 'ssh -p %s %s@%s %s'%(port, id, ip, command)
        mode = 'RemoteCommand'
        return self.delegate(pw, mode, cmd)



def pexpect_test():
        
    rssh = myRSSH()
    rssh.timeout = 5
    rssh.register('cluster_1', '10.2.8.191', 22, 'root','manager' )
    
    # netstat -naop | egrep '(8511)'|grep LISTEN|grep -v grep| sort | awk '{print $7}' | cut -d / -f 1 | xargs kill -9
    # cmd = "netstat -naop | egrep '(%s)'|grep LISTEN|grep -v grep| sort | awk '{print $7}' | cut -d / -f 1 | xargs kill -9" % port
    # cmd = "netstat -naop | egrep '(%s)'|grep LISTEN|grep -v grep| sort | awk '{print $7}' | cut -d / -f 1" % port
    # params_map['command'] = """ps -ef -L | grep python; netstat -naop | egrep '(%s)'""" % ('8511|8512')
    # alias cmport = 'netstat -naop | egrep '\''(8501|8502|8503|8504|8510|8511|8512)'\''|grep LISTEN|sort'
    # ps -ef | egrep '(haproxy|redis)' | grep -v egrep | wc -l
    # netstat -naop | egrep '(8501|8502|8503|8504|6379)' | grep LISTEN|sort | awk '{if ($4 && $7) print $4"-"$7}'
     
    print( "#"*80 )
    
    # LJG: egrep 구문(')이 pexpect에서 정상동작하지 않아서 편법으로 다중명령어와 파이썬 명령 활용
    #     원래의도: netstat -naop | egrep '(8501|8502|8503|8504|6379)' | grep LISTEN | sort | awk \\'\\{if ($4 && $7) print $4"-"$7}'
    _cmd = """netstat -naop | grep 6379 | grep LISTEN | grep redis | grep -v grep;
             netstat -naop | grep 8501 | grep LISTEN | grep haproxy | grep -v grep"""            
    cmd = """netstat -naop | egrep \\'(8501|8502|8503|8504|6379)\\' | grep LISTEN |sort | awk \\'{if ($4 && $7) print $4\\"-\\"$7}\\' """
    
    # LJG: pexpect에서 명령어 실행을 성공하려면 ',"와 같은 escape문자에 대한 적절한 처리가 필요하다.
    # 이를 위해서는 아래와 같이 '\\'문자를 escape문자앞에 2번 넣어주어야 한다.
    #    ' -> \\'
    #    " -> \\"
    # 이를 위해 다음과 같은 전처리가 필요 :
    #    cmd = cmd.replace("'", "\\'").replace('"', '\\"')
    # ex)
    #     before: netstat -naop | egrep '(8501|8502|8503|8504|6379)' | grep LISTEN |sort 
    #     after : netstat -naop | egrep \'(8501|8502|8503|8504|6379)\' | grep LISTEN |sort
    
    cmd = """netstat -naop | egrep '(8501|8502|8503|8504|6379)' | grep LISTEN |sort | awk '{if ($4 && $7) print $4" "$7}' """
    print( "before: <%s>" % cmd )
    cmd = cmd.replace("'", "\\'").replace('"', '\\"')   
    print( "CMD: <%s>" % cmd )
    result = rssh.doRemoteCommand ('cluster_1', cmd)
     
    """
    raw format::
    tcp        0      0 0.0.0.0:6379                0.0.0.0:*                   LISTEN      11537/redis-server  off (0.00/0/0)
    tcp        0      0 0.0.0.0:8501                0.0.0.0:*                   LISTEN      32740/haproxy       off (0.00/0/0)
     
    split result::
    ['tcp', '0', '0', '0.0.0.0:6379', '0.0.0.0:*', 'LISTEN', '11537/redis-server', 'off', '(0.00/0/0)']
    ['tcp', '0', '0', '0.0.0.0:8501', '0.0.0.0:*', 'LISTEN', '32740/haproxy', 'off', '(0.00/0/0)']
    """
     
    print( "-"*80 )
    print( "raw format::\n" )
    print( result )
    print( "-"*80 )

    print( "split format::\n")
    for line in result.split('\n'):                
        (protocol, recv_queue, send_queue, local_addr, remote_addr, state, pid_program, timer, etc) = line.split()
        listen_ip, listen_port = local_addr.split(':')
        pid, program           = pid_program.split('/')
        print "program[%20s] pid[%s] :: listen_port[%s]" % (program, pid, listen_port)
         
    print( "-"*80 )        
    print( "#"*80 )
               
# ------------------------------------------------------------------------------
    
# ------------------------------------------------------------------------------    
# sample command
# ------------------------------------------------------------------------------    
COMMAND_PROMPT = '[$#] '
TERMINAL_PROMPT = r'Terminal type\?'
TERMINAL_TYPE = 'vt100'
SSH_NEWKEY = r'Are you sure you want to continue connecting \(yes/no\)\?'

if __name__ == '__main__':
    
    # main routine
    try:
        rssh = myRSSH()
        rssh.timeout = 10
        rssh.register('ctrl',   '10.0.0.101', 22, 'root','ohhberry3333'  )
        rssh.register('cnode02','10.0.0.102', 22, 'root','ohhberry3333'  )
                
        # rssh.debug = True
        
        cmd = 'mysql -p -e "SHOW STATUS;"'
        cmd = "netstat -nao|egrep '\(22\)'"
        cmd = "netstat -nao|egrep '\(LISTEN\|EST\)'|egrep '\(22\|3306\)'"

        # using doRemoteCommand example
        print "#"*80        
        print "### using doRemoteCommand example"
        result = rssh.doRemoteCommand ('ctrl', cmd)
        print result
        print "#"*80

        # using getRemoteShell example        
        print "#"*80        
        print "### using getRemoteShell example"
        ctrl = rssh.getRemoteShell('ctrl')

        ctrl.sendline('uname -a')
        ctrl.expect([pexpect.TIMEOUT, pexpect.EOF, COMMAND_PROMPT], timeout=2)
        result = ctrl.before
        print 'RESULT::'
        print "-"*80
        print result.strip()
        print "-"*80,"\n\n"

        ctrl.sendline('ls -al')
        ctrl.expect([pexpect.TIMEOUT, pexpect.EOF, COMMAND_PROMPT], timeout=2)
        result = ctrl.before
        print 'RESULT::'
        print "-"*80
        print result.strip()
        print "-"*80,"\n\n"
        print "#"*80
                
        ctrl.sendline(cmd)
        ctrl.expect([pexpect.TIMEOUT, pexpect.EOF, COMMAND_PROMPT])
        result = ctrl.before
        print 'RESULT::'
        print "-"*80
        print result.strip()
        print "-"*80,"\n\n"
        print "#"*80
        
        ctrl.close() # -> important        
        
    except Exception, e:
        print "@"*80
        print str(e)
        print "@"*80
        import traceback
        traceback.print_exc()
        print "@"*80        
        os._exit(1)
        
