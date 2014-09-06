package flybook

class Country {

    String name
    String toString(){
        "${name}"
    }

    static constraints = {
        name(nullable: false, blank: false, unique: true)
    }
}
