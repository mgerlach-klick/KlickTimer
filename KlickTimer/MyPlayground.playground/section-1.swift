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


var x: Bool? = false
if x { "does this get evaluated?" }
if x == true { "what about this? does this get evaluated?" }
