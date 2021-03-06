package flybook

class Airport {

    String code
    City city
    String toString() {
        "${city}"
    }

    static constraints = {
        code nullable: false, blank: false, unique: true, size: 3..3
    }
}
