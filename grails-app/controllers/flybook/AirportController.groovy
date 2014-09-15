package flybook


import groovyx.net.http.HTTPBuilder
import static groovyx.net.http.Method.GET
import static groovyx.net.http.ContentType.JSON
import static org.springframework.http.HttpStatus.*
import grails.transaction.Transactional

@Transactional(readOnly = true)
class AirportController {

    static allowedMethods = [save: "POST", update: "PUT", delete: "DELETE"]

    def index(Integer max) {
        params.max = Math.min(max ?: 10, 100)
        respond Airport.list(params), model:[airportInstanceCount: Airport.count()]
    }

    def show(Airport airportInstance) {
        respond airportInstance
    }

    def create() {
        respond new Airport(params)
    }

    @Transactional
    def save(Airport airportInstance) {
        if (airportInstance == null) {
            notFound()
            return
        }

        if (airportInstance.hasErrors()) {
            respond airportInstance.errors, view:'create'
            return
        }

        airportInstance.save flush:true

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.created.message', args: [message(code: 'airport.label', default: 'Airport'), airportInstance.id])
                redirect airportInstance
            }
            '*' { respond airportInstance, [status: CREATED] }
        }
    }

    def edit(Airport airportInstance) {
        respond airportInstance
    }

    @Transactional
    def update(Airport airportInstance) {
        if (airportInstance == null) {
            notFound()
            return
        }

        if (airportInstance.hasErrors()) {
            respond airportInstance.errors, view:'edit'
            return
        }

        airportInstance.save flush:true

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.updated.message', args: [message(code: 'Airport.label', default: 'Airport'), airportInstance.id])
                redirect airportInstance
            }
            '*'{ respond airportInstance, [status: OK] }
        }
    }

    @Transactional
    def delete(Airport airportInstance) {

        if (airportInstance == null) {
            notFound()
            return
        }

        airportInstance.delete flush:true

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.deleted.message', args: [message(code: 'Airport.label', default: 'Airport'), airportInstance.id])
                redirect action:"index", method:"GET"
            }
            '*'{ render status: NO_CONTENT }
        }
    }

    protected void notFound() {
        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.not.found.message', args: [message(code: 'airport.label', default: 'Airport'), params.id])
                redirect action: "index", method: "GET"
            }
            '*'{ render status: NOT_FOUND }
        }
    }

    def request() {
        def listOfAirports = [:]
        Country country
        City city
        def http = new HTTPBuilder('http://www.ryanair.com')
        http.get(path: '/en/api/2/forms/flight-booking-selector/') { resp, json ->
            json.airports.each { listOfAirports.put(it.iataCode, [it.country.name, it.name]) }
        }

        for (code in listOfAirports.keySet()) {
            country = Country.find(new Country(name: listOfAirports[code][0]))
            if (country != null) {
                city = new City(name: listOfAirports[code][1], country: country).save(flush: true)
                new Airport(code: code, city: city).save(flush: true)
            } else {
                country = new Country(name: listOfAirports[code][0]).save(flush: true)
                city = new City(name: listOfAirports[code][1], country: country).save(flush: true)
                new Airport(code: code, city: city).save(flush: true)
            }
        }
    }
}
