#!/usr/bin/env python
# -*- coding: utf-8 -*-

#===========================================================================
# tcl remote-sql-net porting to python
#
#       Network Version of isqltcl
#
#       Created by JinGoo Lee 1997/12/10
#
#       Last Update : 2013/02/10
#
#       Cloud Service Development Team, Korea Telecom
#===========================================================================

import MySQLdb
import MySQLdb.cursors
import sys
import traceback
import pprint

class myRSQL():
 
    def __init__(self):
        self.dbinfo = {}        # db info 
        self.dbhand = {}        # db handle
        self.dbcurs = {}        # db dbcurs
        self.dbstat = {}        # db connection status('CONN', 'DISCONN')

    def connect(self, name, host, id, pw, db, port=3306):        
        if not self.dbinfo.has_key(name):
            """최초 접속 요청인 경우"""
            
            # print "[%s] db register" % name
            
            # 접속 요청 정보 등록
            self.dbinfo[name] = [host, id, pw, db, port]
            self.dbstat[name] = 'DISCONN'        

        if self.dbstat[name] == 'CONN' :
            return
        
        # print "[%s] db connect" % name
        
        # DB 접속
        try:            
            connstr = "(host=%s, port=%d, user=%s, passwd=%s, db=%s)" % (host, port,id, pw, db)
            conn=MySQLdb.connect(host=host, port=port,
                                 user=id, passwd=pw,
                                 db=db)
            # cursorclass = MySQLdb.cursors.SSCursor -> 대용량 데이터 로딩시 필수
            
        except MySQLdb.Error, e:
            raise RuntimeError("Error %d: %s" % (e.args[0], e.args[1]))
     
        print "## [%s] db %s connect succ !!" % (name, connstr)
        self.dbstat[name] = 'CONN'
        self.dbhand[name] = conn
        self.dbcurs[name] = conn.cursor();
        # encoding setting
        self.dbcurs[name].execute("SET names UTF8")
        
    
    def conn_check(self, name):
        if not self.dbinfo.has_key(name):
            raise RuntimeError("RSQL: Invalid DB Connection Name : %s" % name)
        
        if not self.dbstat[name]=='CONN':
            print "[%s] db reconnect try" % name
        
            host, id, pw, db, port = self.dbinfo[name]
            self.connect(name, host, id, pw, db, port)
        
    def finish(self, name):
        """ name 관련 자료구조를 정리하고 DB 접속을 끊는다"""
        
        print "[%s] db finish(delete info & disconn)" % name
         
        if not self.dbinfo.has_key(name):
            raise RuntimeError("RSQL: Invalid DB Connection Name : %s" % name)
        
        self.disconn(name)
        
        del self.dbinfo[name]
        del self.dbhand[name]
        del self.dbcurs[name]         
        
    def disconn(self, name):
        """name 관련  데이터베이스 접속을 끊는다. """
        print "[%s] db disconn" % name
        
        if not self.dbhand.has_key(name):
            # raise RuntimeError("RSQL: Invalid DB Connection Name : %s" % name)
            raise "RSQL: Invalid DB Connection Name : %s" % name
    
        self.dbcurs[name].close()
        self.dbhand[name].close()
        self.dbstat[name] = 'DISCONN'       
            
    def fetch(self, name, query):
        self.conn_check(name)
        dbcurs = self.dbcurs[name]
        dbcurs.execute(query)
        return dbcurs

    def getfields(self, name):
        dbcurs = self.dbcurs[name]
        fields   = ""
        for desc in dbcurs.description:
            colname = desc[0]
            fields += colname + ','        
        return fields.strip(',')
               
    def colheader(self, name):
        dbcurs = self.dbcurs[name]
        fmt1 = ""
        fmt2 = ""
        ch   = ""
        for desc in dbcurs.description:
            #print "  => %s" % str(desc)
            colname = desc[0]
            collen  = desc[2]
            
            fmt1 = '%'+str(collen)+'s,'
            fmt2 += fmt1 % colname
            
            # 컬럼 길이에 맞추면 오히려 더 보기 불편
            ch += colname + ', '
            
        return ch
    
    def allwithcolnames(self, name, query):
        dbcurs = self.dbcurs[name]
        
        dbcurs.execute(query)
        columns = dbcurs.description
        result = []
        for value in dbcurs.fetchall():
            tmp = {}
            for (index,column) in enumerate(value):
                tmp[columns[index][0]] = column                
            result.append(tmp)
            
        # pprint.pprint(result)
        return result
        
    def bigdata(self, name, query, num=50):
        """ 
        bigdata 질의 전용
                테이블 레코드가 10만개이상을 bigdata라 가정하면,
                사용자가 select all을 하는 순간 mysql clinet는 모든 레코드를 가져와서 처리하는 구조이기때문에
                프로그램이 hang 걸린다. 이를 해결하기 위해서는
                접속할때 Server Side dbcurs를 이용하여 클라이언트에서 하나씩 가져와 처리하는 구조를 사용하자
                물론 가능하면 chunk단위로 읽을수 있으면 효율적일 것이다.        
        """
        
        if self.dbinfo.has_key(name):
            self.disconn(name)
         
        # DB 접속
        try:            
            host, id, pw, db, port = self.dbinfo[name]
            print "connect(host=%s, port=%d, user=%s, passwd=%s, db=%s, cursorClass=%s)" % (host,port,id,pw,db,MySQLdb.cursors.SSCursor)
            conn=MySQLdb.connect(host=host, port=port,
                                 user=id, passwd=pw,
                                 db=db,
                                 cursorclass = MySQLdb.cursors.SSCursor)
        except MySQLdb.Error, e:
            raise RuntimeError("Error %d: %s" % (e.args[0], e.args[1]))
     
        print "[%s] db connect for bigdata succ !!" % name
        self.dbhand[name] = conn
        self.dbcurs[name] = conn.cursor();
        # encoding setting
        self.dbcurs[name].execute("SET names UTF8")        
        
        cursor = self.dbcurs[name]
        cursor.execute(query)
        fetch=cursor.fetchmany
        while True:
            rows=fetch(num)
            if not rows: break
            yield rows
            #for row in rows:
            #     yield row    
        
        # 다음 질의부터는 일반적인 client side dbcurs 사용하도록 접속 끊는다.
        self.disconn(name)
    
    def all(self, name, query):
        self.conn_check(name)
        
        #print "q:: ", query
        
        dbcurs = self.dbcurs[name]
        dbcurs.execute(query)
        return dbcurs.fetchall()

        
    def all_detail(self, name, query):
        self.conn_check(name)
        dbcurs = self.dbcurs[name]
        dbcurs.execute(query)
        
        print "---------------------------------------"
        print "query => \n[%s]" % query.strip()
        print "---------------------------------------" 
    
        print "recs num :: [%d]" % dbcurs.rowcount
        print "fields   :: " + self.colheader(name)   
        print "---------------------------------------"  
        cnt=0
        result = dbcurs.fetchall()
        for rec in result:
            cnt += 1
            print "  %d => %s" % (cnt, rec)   
        print "---------------------------------------" 


    def num(self, name, num, query):
        self.conn_check(name)
        dbcurs = self.dbcurs[name]
        dbcurs.execute(query)        
        return dbcurs.fetchmany(size=num)
                  
    def one(self, name, query):
        self.conn_check(name)
        dbcurs = self.dbcurs[name]
        dbcurs.execute(query)
        return dbcurs.fetchone()    
    
    def run(self, name, query, auto_commit=True):
        self.conn_check(name)
        db     = self.dbhand[name]
        dbcurs = self.dbcurs[name]
        
        try:
            # Execute the SQL command
            dbcurs.execute(query)            
            # Commit your changes in the database
            if auto_commit: db.commit()
            
        except MySQLdb.Error, e:            
            # Rollback in case there is any error
            if auto_commit: db.rollback()
            raise RuntimeError("Error %d: %s" % (e.args[0], e.args[1]))

    

if __name__ == '__main__':

    dh = myRSQL()
    dtag    = "havana"
    db_host = "211.224.204.147"
    db_id   = "root"
    db_pw   = "ohhberry3333"
    base_db = "nova"
    # conect
    dh.connect(dtag, db_host, db_id, db_pw, base_db)
    q = "select * from instances limit 3"
    
    # sql_all test
    recs = dh.all(dtag,q)
    print "\n\n# all : ", recs
    dh.disconn(dtag)
    
    # sql_num test
    recs = dh.num(dtag, 5, q)
    print "\n\n# num 5: ", recs
    # dh.connect(dtag, "10.2.8.154", "rdbaas","manager","rdbaas_management")
    
    # sql_one test
    rec = dh.one(dtag, q)
    print "\n\n# one: ", rec
    dh.all_detail(dtag, q)
    
    print "\n\n# bigdata: "    
    # bigdata test (중요기능)        
    bdtag = "bigdata"
    # 동일계정인 경우
    # dh.connect(bdtag, "172.27.205.154",bdtag,bdtag,"TPCC", 3306)
    # 다른 계정인 경우
    dh.connect(bdtag, db_host, db_id, db_pw, base_db)
    cnt=0 
    for recs in dh.bigdata(bdtag, "select * from vw_vm_trace",50):
        print "## chunk\n"
        for rec in recs:
            vm_name, action, event, start_time, finish_time, result, traceback = rec
            cnt += 1
            print "%d %s" % (cnt, rec)  
                      
    dh.all_detail(bdtag, "select * from vw_vm_trace limit 20")
    
    
    dh.all_detail(bdtag, "select * from vw_vm_inventory limit 20")
    
    
