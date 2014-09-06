@Grab(group = 'org.codehaus.groovy.modules.http-builder', module = 'http-builder', version = '0.7')

import groovyx.net.http.HTTPBuilder
import static groovyx.net.http.Method.GET
import static groovyx.net.http.ContentType.JSON

def http = new HTTPBuilder('http://www.ryanair.com')

def listOfAirports = [ : ]

http.get(path: '/en/api/2/forms/flight-booking-selector/') {resp, json ->
    json.airports.each { listOfAirports.put(it.iataCode, [it.country.name, it.name])}}
    

new File('E:\\httpreq.txt').withWriter {out ->
    listOfAirports.each() {key, value ->
        out.write("${value[0]} - ${value[1]} - ${key}" + "\n")}}