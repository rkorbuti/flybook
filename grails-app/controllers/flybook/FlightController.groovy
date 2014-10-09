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
        def http = new HTTPBuilder('http://www.ryanair.com')
        def from = Airport.get(params.airportFrom.id), to = Airport.get(params.airportTo.id)
        def departure = params.departureTime.format("yyyy-MM-dd"), arrival = params.arrivalTime.format("yyyy-MM-dd"), prc = params.price
        def path = '/en/api/2/flights/from/' + from.code + '/to/' + to.code + '/' + departure + '/' + arrival + '/outbound/cheapest-per-day/'
        http.get(path: path) {resp, json ->
            json.flights.each { listOfFlights << [it.dateFrom, it.dateTo, it.price.value + it.price.currencySymbol]}
        }
        [from: from, to: to, list: listOfFlights]
    }
}
