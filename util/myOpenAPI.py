#!/usr/local/bin/python -B
# -*- coding: utf-8 -*-

import sys
import urllib2
import urllib
import json
import hmac
import base64
import hashlib
import re
import pprint
import time
import traceback

class SmartRedirectHandler(urllib2.HTTPRedirectHandler):     
    def http_error_301(self, req, fp, code, msg, headers):  
        result = urllib2.HTTPRedirectHandler.http_error_301(
            self, req, fp, code, msg, headers)              
        result.status = code                                 
        return result                                       

    def http_error_302(self, req, fp, code, msg, headers):
        result = urllib2.HTTPRedirectHandler.http_error_302(
            self, req, fp, code, msg, headers)              
        result.status = code                                
        return result 
    
#-------------------------------------------------------------------------------
class Adapter(object):

    #---------------------------------------------------------------------------
    def __init__(self, api, apikey, secret):
        self.api = api
        self.apikey = apikey
        self.secret = secret

    #---------------------------------------------------------------------------
    def iscommandasync(self, group, command):
        """need to check whether command is async or not"""
        
        cmd_ctx = Context("./conf/command_list.conf")
        cmdtype = cmd_ctx.get(group, command)
        return cmdtype
    
    #---------------------------------------------------------------------------
    def makeurlcommand(self, command, args):
        """openapi를 호출하기 위한 명령어를 생성한다."""
        
        args['apikey'] = self.apikey
        args['command'] = command
        args['response'] = 'json'
        
        params = []        
        keys = sorted(args.keys())
        for k in keys:
            params.append(k + '=' + urllib.quote_plus(args[k])) 
       
        query = '&'.join(params)
        signature = base64.b64encode(hmac.new(
            self.secret,
            msg=query.lower(),
            digestmod=hashlib.sha1
        ).digest())

        query += '&signature=' + urllib.quote_plus(signature)
                
        return query
    
    def call_request(self, query, type='urllib2'):
        """
            특정 HTTP 모듈을 이용해서 openapi를 호출한다.
                    
            1. urllib2 -> default            
            2. curl -> 다양한 옵션을 활용하기 위해 사용, 특히 redirect
                            현재 RDBaaS가 302 moved를 사용하므로 curl을 이용하는 것이 손쉽다.
                            그렇지 않으면 urllib에서 결과 헤더를 항상 분석하고 그 결과를 적용하는 로직을 구현해야 한다.                
        """
            
        if type == 'curl':
            
            curlcmd = "curl -v -L -s -S -k %s" % (query)
            import subprocess
            
            # check_output을 사용하면 stderr 출력을 찍을수 없다. 
            # response = subprocess.check_output(curlcmd)
            
            # 현재 -v 옵션을 주면 해당 메시지가 stderr로 나오기때문에 Popen방식을 사용해야 한다.
            proc = subprocess.Popen(curlcmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            (response, err) = proc.communicate()
            proc.stdout.close()
            proc.stderr.close()
            
            if err:
#                log(err)
                print "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
                print err
                print "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
                
                
            cmd = curlcmd 
               
        else:
            
            """
            ######################################
            # how to debug urlhttp2
            ######################################
            
            >>> handler=urllib2.HTTPHandler(debuglevel=1)
            >>> opener = urllib2.build_opener(handler)
            >>> urllib2.install_opener(opener)
            >>> urllib2.urlopen('http://diveintomark.org/xml/atom.xml').read()
            
            send: 
                'GET /xml/atom.xml HTTP/1.1\r\n
                Accept-Encoding: identity\r\n
                Host: diveintomark.org\r\n
                Connection: close\r\n
                User-Agent: Python-urllib/2.7\r\n\r\n'
                
            reply: 'HTTP/1.1 200 OK\r\n'
                header: Cache-Control: no-cache            
                header: Pragma: no-cache            
                header: Content-Type: text/html; charset=utf-8            
                header: Expires: -1            
                header: Server: Microsoft-IIS/7.5            
                header: X-AspNet-Version: 4.0.30319            
                header: Set-Cookie: fc=fcVal=8701532910292928512; domain=diveintomark.org; expires=Fri, 01-Jan-2038 07:00:00 GMT; path=/            
                header: X-Powered-By: ASP.NET            
                header: Date: Sat, 26 Jan 2013 10:57:19 GMT            
                header: Content-Length: 28706            
                header: Age: 0            
                header: Connection: close
            """
            
            # ch = urllib2.urlopen(query)
            request = urllib2.Request(query)
            import httplib
            httplib.HTTPConnection.debuglevel = 1
            opener = urllib2.build_opener(SmartRedirectHandler())
            ch = opener.open(request)
            
            # notice ::
            # error 가 발생하면 data가 xml 형태로 에러메시지를 전달한다.
            # 따라서 error 발생시에는 이 메시지를 보여주어야 한다.
            response = ch.read()
            cmd = query
                  
#        log(cmd)
        return response     
        
    #---------------------------------------------------------------------------
    def request(self, command, args):
        '''open api command request'''
      
        query = self.makeurlcommand(command, args)
        urlcommand = self.api + '?' + query
        print "urlcommand <%s>" % urlcommand
        
        data = ""
        try:
            
            # data = self.call_request(urlcommand, 'curl')
            data = self.call_request(urlcommand)
            print data
            
        except urllib2.URLError, e:
            """
            Often, URLError is raised because there is no network connection (no route to the specified server), or 
            the specified server doesn’t exist. In this case, the exception raised will have a ‘reason’ attribute, 
            which is a tuple containing an error code and a text error message.
            """
            
            print "inside URLError "
            errmsg = "\n    ####################################################\n"
            errmsg += "    URLError 에러 메시지:: \n"     
            errmsg += "        URLError: %s\n" % e
            raise RuntimeError(errmsg)
        except urllib2.HTTPError, e:
            """
            Every HTTP response from the server contains a numeric “status code”. 
            Sometimes the status code indicates that the server is unable to fulfil the request. 
            The default handlers will handle some of these responses for you 
            (for example, if the response is a “redirection” that requests the client fetch the document from a different URL, 
            urllib2 will handle that for you). For those it can’t handle, urlopen will raise an HTTPError. 
            Typical errors include ‘404’ (page not found), ‘403’ (request forbidden), and ‘401’ (authentication required).

            See section 10 of RFC 2616 for a reference on all the HTTP error codes.
            The HTTPError instance raised will have an integer ‘code’ attribute, which corresponds to the error sent by the server.
            """
            print "inside HTTPError "
            errmsg = "\n    ####################################################\n"
            errmsg += "    에러 메시지:: \n"     
            errmsg += "        HTTPError Code : %s\n" % e.code
            errmsg += "        HTTPError Msg  : %s\n" % e.read()
            raise RuntimeError(errmsg)            
        except Exception, e:
            print "inside Exception "
            #
            # 종합적인 에러메시지 생성
            errmsg = "\n    ####################################################\n"
            errmsg += "    수신 데이터:: \n"
            errmsg += "    Exception 에러정보:: %s \n" % e
            for line in data.splitlines():
                errmsg += "        %s\n" % line
            errmsg += "    Exception 에러 메시지:: \n"                
            formatted_lines = traceback.format_exc().splitlines()
            for line in formatted_lines:
                errmsg += "        %s\n" % line
            errmsg += "    ####################################################\n"
            raise RuntimeError(errmsg)
        
        """
            # notice !!
            #            
            # 정상적인 응답이 온 경우에나 json으로 변환이 가능하다.
            # 그러나, 에러가 난 경우에는 서버에서 xml을 전송해 주어서
            # json.loads()함수가 에러를 발생시키므로
            # 여기서 string 레벨의 에러검사가 필요하다.
            """           
        
        decoded = json.loads(data)            
            
        propertyResponse = command.lower() + 'response'                          
        if not propertyResponse in decoded:        
            if 'errorresponse' in decoded:                
                errmsg = "\n    ####################################################\n"
                errmsg += "    수신 데이터:: \n"
                for line in data.splitlines():
                    errmsg += "        %s\n" % line
                errmsg += "    errorresponse 에러 메시지:: \n"
                
                if 'errortext' in decoded['errorresponse']:
                    # cloudstack case
                    errmsg += "        %s\n" % decoded['errorresponse']['errortext']
                    errmsg += "    ####################################################\n"
                    raise RuntimeError(errmsg)
                        
                elif 'description' in decoded['errorresponse']:
                    # ucloud-db case
                    errmsg += "        %s\n" % decoded['errorresponse']['description']
                    errmsg += "    ####################################################\n"
                    raise RuntimeError(errmsg)
            else:
                errmsg += "        %s\n" % "ERROR: Unable to parse the response"
                errmsg += "    ####################################################\n"
                raise RuntimeError(errmsg)

        response = decoded[propertyResponse]        
        result = re.compile(r"^list(\w+)s").match(command.lower())
        
        if not result is None:
            type = result.group(1)

            if type in response:
                return response[type]
            else:
                # sometimes, the 's' is kept, as in :
                # { "listasyncjobsresponse" : { "asyncjobs" : [ ... ] } }
                type += 's'
                if type in response:
                    return response[type]

        return response

    #---------------------------------------------------------------------------
    def requestAutoPoll(self, command, args):
        '''모든 명령에 대한 결과를 리턴한다.
          명령이 동기식인지 비동기식인지 파악하여 
          비동기식인 경우 자동으로 명령을 폴링하여 결과를 리턴'''
    
        params = args
        response = {}
        jobid = None
        objs = None
        
        try:
            objs = self.request(command, args)                
            
            jobid = objs['jobid']
            cmdtype = self.iscommandasync('ucloud-db', command)
                   
            if cmdtype == 'async':
       
                sleep_sec = 10
                while True:  
                    command = "queryAsyncJobResult"
                    args = { 'jobid':jobid }
                    cmd_tpl = "%s.request('%s',%s)" % ('self', command, args)
                    
#                    log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
#                    log("%s REQUEST :: " % cmd_tpl) 
#                    log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
    
                    objs = eval(cmd_tpl)
                    # pprint.pprint(objs, )
                
                    # 0 : 진행중
                    # 1 : 성공
                    # 2 : 실패
            
                    jobstatus = objs['jobstatus']
#                    log("jobstatus <%s>" % jobstatus)
                    
                    if jobstatus == '2':
#                        log(objs['jobresult'])
                        break            
                    if jobstatus == '1':
                        break
                    if jobstatus == '3':
                        # 이건 RDBaaS 고유 산물 
                        # multiaz에서 대충 만들어 놈 -> 엉터리 이노츠                        
                        break
                            
#                    log("    !!! %s sec sleep, tired !!! " % sleep_sec)
                    time.sleep(sleep_sec)
        
        except Exception, errmsg:
            response['jobid'] = jobid
            response['command'] = command
            response['params'] = params
            response['succ'] = False            
            response['data'] = errmsg
            return response            
        
        response['jobid'] = jobid
        response['command'] = command
        response['params'] = params
        response['succ'] = True
        response['data'] = objs        
        return response

#-------------------------------------------------------------------------------
import ConfigParser
class Context:
    """open api related config -> context load"""

    def __init__(self, config_file):
        cfg = ConfigParser.ConfigParser()
        cfg.read(config_file)
        self.cfg = cfg

    #
    # open api call env info

    def sections(self):
        return self.cfg.sections()

    def get(self, group, key):
        return self.cfg.get(group, key)
   
#-------------------------------------------------------------------------------
def split_by_length(s, block_size):
    """스트링을 일정길이로 잘라서 리스트로 돌려준다."""
    w = []
    n = len(s)
    for i in range(0, n, block_size):
        w.append(s[i:i + block_size])
    return w

# 모든 자료구조를 파악하여 예쁘게 출력
def myprint(obj, indent=2):
    """
    모든 자료구조를 파악하여 예쁘게 출력.
    딕셔너리는 키값으로 소트하여 예쁘게 보여준다.
    """
    space = '  '
        
    if isinstance(obj, list):
        # 리스트인 경우
#        log("%s %s" % (space * (indent), '['))
        
        for value in obj:
            if isinstance(value, list):
#                if gflag: log("dict inside list")
#                log("%s %-20s -> %s" % (space * (indent + 1), str(value), len(value)))
                myprint(value, indent + 2)
            elif isinstance(value, dict):
#                if gflag: log("dict inside list")
                myprint(value, indent + 2)
            else:
#                log("%s %s " % (space * (indent + 1), str(value)))
                pass
                
#        log("%s %s" % (space * (indent), ']'))
        
    elif isinstance(obj, dict):
        # 딕셔너리인 경우      
#        log("%s %s" % (space * (indent), '{'))
          
        keylist = obj.keys()
        # keylist.sort()  
        for key in keylist:
            value = obj[key]
            if isinstance(value, list):                
#                if gflag: log("list inside dict")
#                log("%s %-20s -> %s" % (space * (indent + 1), str(key), len(value)))
                myprint(value, indent + 2)
            elif isinstance(value, dict):
#                if gflag: log("dict inside dict")
#                log("%s %-20s -> %s" % (space * (indent + 1), str(key), len(value)))
                myprint(value, indent + 2)
            else:                
#                log("%s %-20s -> %s" % (space * (indent + 1), str(key), str(value)))
                pass
#        log("%s %s" % (space * (indent), '}'))
    else:
        # 그외 자료구조인 경우
#        log("%s %s " % (space * (indent + 1), str(obj)))
        pass

