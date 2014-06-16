var maybeAName : String? = .None


func handleMaybeStr (maybeName : String?) -> Void {
	if let name = maybeName {
		println("Hello \(name)")
	} else {
		println("Hello to no one in particular")
	}
}


handleMaybeStr(maybeAName)

maybeAName = "Steve"
handleMaybeStr(maybeAName)

struct TicketList {
	static var activeTicket: String? {
		willSet {
			if let a = activeTicket {
			println("Setting \(activeTicket) to \(newValue)")
			} else {
				println("Setting initial value to \(newValue)")
			}
	}
	}
}


TicketList.activeTicket = "ASDF"

let foo = TicketList()
foo.activeTicket = "bla"
