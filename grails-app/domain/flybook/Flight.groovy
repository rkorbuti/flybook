package flybook

class Flight {

    Airport airportFrom
    Airport airportTo
    Date departureTime
    Date arrivalTime
    Double price
    boolean enabled

    static constraints = {
        airportFrom()
        airportTo()
        departureTime()
        arrivalTime()
        enabled()
        price()
    }


}
