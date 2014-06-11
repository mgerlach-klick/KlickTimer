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

maybeAName = 123