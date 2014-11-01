package flybook


import groovyx.net.http.HTTPBuilder
import static groovyx.net.http.Method.GET
import static groovyx.net.http.ContentType.JSON
import static org.springframework.http.HttpStatus.*
import grails.transaction.Transactional

@Transactional(readOnly = true)
class FlightController {

    static allowedMethods = [save: "POST", update: "PUT", delete: "DELETE"]

    def index(Integer max) {
        params.max = Math.min(max ?: 10, 100)
        respond Flight.list(params), model:[flightInstanceCount: Flight.count()]
    }

    def show(Flight flightInstance) {
        respond flightInstance
    }

    def searchFlights() {
        respond new Flight(params)
    }

    @Transactional
    def save(Flight flightInstance) {
        if (flightInstance == null) {
            notFound()
            return
        }

        if (flightInstance.hasErrors()) {
            respond flightInstance.errors, view:'searchFlights'
            return
        }

        flightInstance.save flush:true

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.created.message', args: [message(code: 'flight.label', default: 'Flight'), flightInstance.id])
                redirect flightInstance
            }
            '*' { respond flightInstance, [status: CREATED] }
        }
    }

    def edit(Flight flightInstance) {
        respond flightInstance
    }

    @Transactional
    def update(Flight flightInstance) {
        if (flightInstance == null) {
            notFound()
            return
        }

        if (flightInstance.hasErrors()) {
            respond flightInstance.errors, view:'edit'
            return
        }

        flightInstance.save flush:true

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.updated.message', args: [message(code: 'Flight.label', default: 'Flight'), flightInstance.id])
                redirect flightInstance
            }
            '*'{ respond flightInstance, [status: OK] }
        }
    }

    @Transactional
    def delete(Flight flightInstance) {

        if (flightInstance == null) {
            notFound()
            return
        }

        flightInstance.delete flush:true

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.deleted.message', args: [message(code: 'Flight.label', default: 'Flight'), flightInstance.id])
                redirect action:"index", method:"GET"
            }
            '*'{ render status: NO_CONTENT }
        }
    }

    protected void notFound() {
        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.not.found.message', args: [message(code: 'flight.label', default: 'Flight'), params.id])
                redirect action: "index", method: "GET"
            }
            '*'{ render status: NOT_FOUND }
        }
    }

    def getFlights() {
        def listOfFlights = [ ]
        def baseUrl = 'http://www.ryanair.com', http = new HTTPBuilder(baseUrl)
        def from = (params.airportFrom.id != 'null') ? Airport.get(params.airportFrom.id) : null, to = (params.airportTo.id != 'null') ? Airport.get(params.airportTo.id) : null
        def departure = params.departureTime.format("yyyy-MM-dd"), arrival = params.arrivalTime.format("yyyy-MM-dd"), prc = params.price, urlLink = ''

        if (to == null) {
            def path = '/en/api/2/flights/from/' + from.code + '/' + departure + '/' + arrival + '/' + prc + '/unique/'
            http.get(path: path, query: [limit: 200, offset: 0]) {resp, json ->
                json.flights.each {listOfFlights << [it.outbound.airportTo.name, it.outbound.dateFrom.toString().substring(0, 10) + " " + it.outbound.dateFrom.toString().substring(11, 16),
                                                     it.outbound.dateTo.toString().substring(0, 10) + " " + it.outbound.dateTo.toString().substring(11, 16), it.outbound.price.value + it.outbound.price.currencySymbol,
                                                     baseUrl + it.summary.flightViewUrl]}
            }
        }
        //Getting Departure Time, Arrival Time and Price, formatting Departure Time and Arrival Time to be represented as "yyyy-MM-dd HH:mm"
        else {
            def path = '/en/api/2/flights/from/' + from.code + '/to/' + to.code + '/' + departure + '/' + arrival + '/outbound/cheapest-per-day/'
            http.get(path: path) { resp, json ->
                json.flights.each {
                    if (it.price != null && Integer.parseInt(it.price.valueMainUnit) < Double.parseDouble(prc))
                        listOfFlights << [it.dateFrom.toString().substring(0, 10) + " " + it.dateFrom.toString().substring(11, 16),
                                          it.dateTo.toString().substring(0, 10) + " " + it.dateTo.toString().substring(11, 16), it.price.value + it.price.currencySymbol]
                }
            }

            //Getting url link to flights booking page on www.ryanair.com
            def pathForURL = '/en/api/2/flights/from/' + from.code + '/to/' + to.code + '/' + departure + '/' + arrival + '/' + prc + '/unique/'
            http.get(path: pathForURL, query: [limit: 15, offset: 0]) { resp, json ->
                urlLink = json.flights.summary.flightViewUrl
            }
            urlLink = baseUrl + urlLink[0].substring(0, urlLink[0].length() - 10)

            //Adding to the listOfFlights <out date> value for using it in url link from application to flights booking page on www.ryanair.com
            for (int i = 0; i < listOfFlights.size(); i++) {
                listOfFlights[i] += listOfFlights[i][0].toString().substring(0, 10)
            }
        }
        //passing parameters to getFlights view
        [from: from, to: to, list: listOfFlights, flightUrl: urlLink]
    }
}
