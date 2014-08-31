@Grab(group = 'org.codehaus.groovy.modules.http-builder', module = 'http-builder', version = '0.7')

import groovyx.net.http.HTTPBuilder
import static groovyx.net.http.Method.GET
import static groovyx.net.http.ContentType.JSON

def http = new HTTPBuilder('http://www.ryanair.com')

http.get(path: '/en/api/2/forms/flight-booking-selector/') {resp, json ->
    println json.airports.name
}