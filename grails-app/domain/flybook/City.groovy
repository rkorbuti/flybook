package flybook

class City {

    String name
    Country country
    String toString(){
        "${name}"
    }

    static constraints = {
        name(nullable: false, blank: false, unique: true)
    }
}
