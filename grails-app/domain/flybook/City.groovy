package flybook

class City {

    String name
    Country country

    static constraints = {
        name(nullable: false, blank: false, unique: true)
    }
}
