#! /usr/bin/python

'''
Created on Nov 27, 2015

@author: brian
'''
###########################
# TRUE / FALSE
debug = "TRUE"
###########################

import requests
import json
import time
import sys
import pprint
import time

port="8080"
server='http://devjenkins.use1dev1.zonoff.io'
build_details=[]


#---------
def getBuildURLs(job_name):
    #builds_resonse = requests.get( server + ':' + port + '/job/' + job_name + '/api/json?pretty=true&tree=builds[number,url]')
    builds_resonse = requests.get( server + ':' + port + '/job/' + job_name + '/api/json?pretty=true&tree=allBuilds[number,url]')

    #print "==========================="
    #print builds_resonse
    #print "==========================="

    #return json.loads(str(builds_resonse.content))['builds']
    return json.loads(str(builds_resonse.content))['allBuilds']
#---------


#---------
def getBuildDetails(build_url_base):
    #request_url = build_url_base + 'api/json?pretty=true&tree=result,timestamp'
    request_url = build_url_base + 'api/json?pretty=true&tree=number,duration,timestamp,result'
    build_response = requests.get(request_url)

    #print(build_response.content)

    return json.loads(build_response.content)
#---------


#---------
def buildsRecentEnoughToQualify(prior_build_detail, report_start):
    if prior_build_detail['timestamp'] >= report_start:
        return True
    else:
        return False
#---------


#---------
def buildsOldEnoughToQualify(prior_build_detail, report_end):
    if prior_build_detail['timestamp'] >= report_end:
        return False
    else:
        return True
#---------


#---------
def reportOnPassedBuilds(job, build_details, since, until):

    results = {};
    num_builds=0;

    for build_detail in build_details:
        if not results.has_key(build_detail['result']):
            results[build_detail['result']]=1
        else:
            results[build_detail['result']]+=1

    for status in ['SUCCESS', 'UNSTABLE', 'FAILURE']: #ignore ABORTED
        if results.has_key(status):
            num_builds += results[status]
            #print status, results[status]

    if results.has_key('SUCCESS'):
        print " (green builds %):\t" + str(results['SUCCESS'] * 100 / num_builds) + "%"
#---------


#---------
def reportOnGreenTime(job, build_details, since, until):

    #set the starting point to now
    #report_run_time = {'timestamp' : int(time.time()*1000), 'status' : 'Undefined'};
    report_run_time = {'timestamp' : until, 'status' : 'Undefined'};
    reference_point_build_detail = report_run_time
    prior_build_status = 'SUCCESS'
    time_green = 0
    time_success = 0
    time_unstable = 0
    time_aborted = 0
    time_failure = 0
    time_total = 0
    total_count = 0

    for prior_build_detail in build_details:

        # work back in time to find the first build that is old enough to qualify...
        if not buildsOldEnoughToQualify( prior_build_detail, until):
            continue

        #############################################################
        # now until the builds are not too old to qualify...
        if buildsRecentEnoughToQualify(prior_build_detail, since):
 
            #############################################################
            #print dir(prior_build_detail)
            #json.dumps(prior_build_detail)
            #print dict([attr, getattr(prior_build_detail, attr)] for attr in dir(prior_build_detail) if not attr.startswith('_'))
            #print prior_build_detail

            build_status = prior_build_detail['result']
            build_time = prior_build_detail['timestamp']
            duration = reference_point_build_detail['timestamp'] - build_time
            jobNum = prior_build_detail['number']
            humanTime = time.strftime("%Y/%m/%d, %H:%M:%S", time.localtime((prior_build_detail['timestamp'] / 1000 )))

            time_total += duration
            total_count += 1

            #print( build_status + ":" + str(build_time) + " " + str(duration))
            #print( time.strftime("%x %X", time.gmtime(build_time/1000)))

            if build_status == "SUCCESS":

                time_success += duration

                if debug == "TRUE" : print "" + str(build_status) + " | " + str(jobNum) + " | " + str(humanTime) + " | " + str(time_success) + " | S"

            if build_status == "UNSTABLE":

                time_unstable += duration

                if debug == "TRUE" : print "" + str(build_status) + " | " + str(jobNum) + " | " + str(humanTime) + " | " + str(time_unstable) + " | U"

            if build_status == "ABORTED":

                time_aborted += duration

                if debug == "TRUE" : print "" + str(build_status) + " | " + str(jobNum) + " | " + str(humanTime) + " | " + str(time_aborted) + " | A"

            if build_status == "FAILURE":

                time_failure += duration

                if debug == "TRUE" : print "" + str(build_status) + " | " + str(jobNum) + " | " + str(humanTime) + " | " + str(time_failure) + " | F"

            reference_point_build_detail = prior_build_detail

        else:
            # if the last build before the report period was green then count the time
            # from the start of the report period to the first build in the period.
            if prior_build_detail['result'] == "SUCCESS":

                reference_point_build_detail = prior_build_detail

                #time_green += reference_point_build_detail['timestamp'] - since;

#                if debug == "TRUE" : print "" + str(build_status) + " | " + str(jobNum) + " | " + str(time_green) + " | BOOM"
                if debug == "TRUE" : print "" + str(build_status) + " | " + str(jobNum) + " | " + str(humanTime) + " | " + str(time_failure) + " | BOOM"

            if debug == "TRUE" : print "---------"

            break

    report_period = report_run_time["timestamp"] - since
    sum_good = time_success
    sum_bad = ( int(time_unstable) + int(time_aborted) + int(time_failure))
    percent_good = ( int(sum_good) / float(time_total) ) * 100
    percent_bad = ( int(sum_bad) / float(time_total) ) * 100

    #print(job + " (green time %): \t" + str(int(float(time_green)*100/report_period)) + "%"),
    if debug == "TRUE" :
        print "==========================="
        print "Success: " + str(time_success) + ""
        print "Unstable: " + str(time_unstable) + ""
        print "Aborted: " + str(time_aborted) + ""
        print "FAILED: " + str(time_failure) + ""
        print "Total: " + str(time_total) + ""
        print "Sum Bad: " + str(sum_bad) + ""
        print "---------"

    print "Total Count: "+ str(total_count) +""
    print "Percent Good: {0:.0f}%".format(float(percent_good)) + ""
    print "Percent Bad: {0:.0f}%".format(float(percent_bad) ) + ""
#---------


#---------
def validateCommandLine():
    if len(sys.argv) != 4:
        print('syntax: ./uptime.py <jenkins job> <from date> <to date>')
        print('example: ./uptime.py system-int-BUILD-FLOW-MASTER 11/1/15 12/1/15')
        exit(-1)
#---------

validateCommandLine()
#print("Retrieving Build Information... ")
job = str(sys.argv[1])

#print "OFFSET: " + str( ((time.timezone / 60) / 60) )

offset = time.timezone
since = int(((time.mktime(time.strptime(sys.argv[2], "%x"))) - offset) * 1000)
until = int(((time.mktime(time.strptime(sys.argv[3], "%x"))) - offset) * 1000)


if debug == "TRUE" :
    print "since %s until %s" % (since, until)
    print "offset: " + str(offset) + " ||| since: " + str(since) + " ||| " + str(time.strptime(sys.argv[2], "%x")) + " ||| " + str(time.mktime(time.strptime(sys.argv[2], "%x"))) + ""

#exit()

for build in getBuildURLs(job):
    build_details.append(getBuildDetails(build['url'])) 

reportOnGreenTime(job, build_details, since, until )
#reportOnPassedBuilds(job, build_details, since, until)
