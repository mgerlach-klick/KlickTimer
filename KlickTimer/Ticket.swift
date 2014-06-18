//
//  Ticket.swift
//  KlickTimer
//
//  Created by Max Gerlach on 2014-06-09.
//  Copyright (c) 2014 Klick Health. All rights reserved.
//

import Foundation
import Swift

struct TicketList {
	// Properties
	static var activeTicket: Ticket? {
		willSet {
			println("Setting new active ticket as \(newValue?.ticketID)")
			if let t = activeTicket { t.isActive = false }
			if let n = newValue { n.isActive = true }
		}
	}
	
	static var ticketsBySection: Dictionary<String, Ticket[]>?
	
	// Functions
	static func getActiveTicket (completionBlock: ()->() ){
		let userURL = "http://genome.klick.com:80/api/User.json?CurrentUser=true"
		let session = NSURLSession.sharedSession()
		
		let userActiveTicketDataTask = session.dataTaskWithURL(NSURL.URLWithString(userURL)) {
			data, urlresponse, error in
			
			let httpResp = urlresponse as NSHTTPURLResponse
			let jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as NSDictionary

			if let maybeActiveTicketArray : AnyObject = jsonResult.valueForKeyPath("Entries.TicketTracking_TicketID")  {
				if let activeTicketArray = maybeActiveTicketArray as? NSArray {
					let activeTicketId : AnyObject  = activeTicketArray.firstObject as AnyObject
					if activeTicketId as? Int {
						let ticketWithThatID = self.ticketByID(activeTicketId as Int)
						if ticketWithThatID {
							self.activeTicket = ticketWithThatID!
							println("The currently active ticket is \(activeTicketId as Int): \(self.activeTicket!.title)")
							completionBlock()
						}
					} else if activeTicketId as? NSNull {
						println("Currently no active ticket")
					}
				}
			}
		}
		
		userActiveTicketDataTask.resume()
	}
	
	static func ticketByID(id : Int) -> Ticket? {
		if ticketsBySection {
			for array in ticketsBySection!.values {
				for ticket in array {
					if ticket.ticketID == id {
						return ticket
					}
				}
			}
		}
		
		return .None
	}
	

	
	
	static func getAllTickets (completionBlock : (NSArray) -> Void) {
		let ticketURL = "http://genome.klick.com:80/api/Ticket.json?ForGrid=true"
		let session = NSURLSession.sharedSession()
		
		let ticketDataTask = session.dataTaskWithURL(NSURL.URLWithString(ticketURL), completionHandler: {
			data, urlresponse, error in
			
			let httpResp = urlresponse as NSHTTPURLResponse
			let jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as NSDictionary
			
			let entries: NSArray = jsonResult["Entries"] as NSArray
			
			completionBlock(entries as NSArray)
			})
		
		ticketDataTask.resume()
	}
	
	
	static func createOpenTicketList (fromTicketArray tickets: NSArray) {
		let myTickets = tickets
		
		// find open tickets only
		let openTickets : NSArray = myTickets.filteredArrayUsingPredicate(NSPredicate(format: "GroupName == 'OpenForMe'"))
		
		// get distinct project names of open tickets
		let openTicketsProjects : NSArray = openTickets.valueForKeyPath("@distinctUnionOfObjects.ProjectName") as NSArray
		
		// get a list of ticket objects
		let ticketArray : Ticket[] = (openTickets as Array).map {
			ticketDict in
			let jsonDict = ticketDict as NSDictionary
			return Ticket(jsonModel: jsonDict)
		}
		
		// Get a list of tickets partitioned by their project name
		var ticketsBySection = Dictionary<String, Ticket[]>()
		for project : AnyObject in openTicketsProjects {
			let projectName = project as String
			if ticketsBySection[projectName] == nil {
				ticketsBySection[projectName] = Ticket[]()
			}
			
			ticketsBySection[projectName] = ticketArray.filter { $0.projectName == projectName }
			
			/*
			for (key, value) in ticketsBySection {
				println("\(key)")
				for v in value {
					println("- \(v.title)")
				}
			}
			*/
		}
		
		self.ticketsBySection = ticketsBySection
	}
	
	
	static func refreshTicketList (completionBlock : () -> Void) {
		getAllTickets {
			println("Got all tickets!")
			self.createOpenTicketList(fromTicketArray: $0)
			completionBlock()
		}
	}


}





class Ticket : Equatable {
	var title:String, ticketID:Int, projectName:String
	var isActive = false
	
	init (jsonModel: NSDictionary ) {
		title = jsonModel["Title"] as String
		ticketID = jsonModel["TicketID"] as Int
		projectName = jsonModel["ProjectName"] as String
	}
	
	func startTracking (completionBlock : ()->Void) {
		trackingRequest(true, completionBlock)
	}
	
	func stopTracking (completionBlock : ()->Void) {
		trackingRequest(false, completionBlock)
	}
	
	func trackingRequest (startTracking : Bool, completionBlock : ()->Void) {
		let ticketTrackingURL = "http://genome.klick.com:80/api/Ticket/Tracking"
		let params = "TicketID=\(ticketID)&StartTracking="+(startTracking ? "true" : "false")
		println("tickettrackingurl: \(ticketTrackingURL)\(params)")
		
		let session = NSURLSession.sharedSession()
		var urlRequest = NSMutableURLRequest(URL: NSURL.URLWithString(ticketTrackingURL))
		urlRequest.HTTPMethod = "POST"
		urlRequest.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
		
		let ticketDataTask = session.dataTaskWithRequest(urlRequest, completionHandler: {
			data, urlresponse, error in

			let httpResp = urlresponse as NSHTTPURLResponse

			var error : NSError?
			
			var jsonResult: NSDictionary? = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: &error) as? NSDictionary
			if jsonResult {
				println(jsonResult)
			} else if error {
				println("JSON Error: \(error.description)")
			}
			
			if httpResp.statusCode == 200 {//&& jsonResult.valueForKeyPath("Validation.IsValid") as String == "true" {
				if startTracking {
					TicketList.activeTicket = self
				} else {
					TicketList.activeTicket = nil
				}
			}
			
			completionBlock()
			
		})
		
		ticketDataTask.resume()
	}
	
	func toggleTracking (completionBlock : ()->Void) {
		if isActive {
			stopTracking(completionBlock)
		} else {
			startTracking(completionBlock)
		}
	}
}

func == (lhs: Ticket, rhs: Ticket) -> Bool {
	return lhs.ticketID == rhs.ticketID
}






/*
let groupNames : Array = results.valueForKeyPath("@distinctUnionOfObjects.GroupName") as NSArray! as Array

// Swift won't let me downcast this directly, i have to force it this way. http://stackoverflow.com/questions/24091370/annotation-error-in-swift-for-loop-with-array-and-uiview
for result: AnyObject in results {
let r = result as NSDictionary as Dictionary
println(r)
}
*/

/*
{
"GroupName": "OpenForMe",
"TicketID": 550533,
"Title": "Investigate Xamarin",
"Created": "/Date(1375895301613-0000)/",
"ProjectID": 9991,
"LastUpdated": "/Date(1401278459510-0000)/",
"AccountPortfolioName": "Systems, Infrastructure, and Platform",
"ProjectName": "smartsite v4",
"CompanyID": 1,
"CompanyName": "Klick Inc.",
"AssignedToUser": "Max Gerlach",
"AssignedByUser": "Cynthia Dahl",
"OwnerUser": "Steve Willer",
"TicketStatusName": "open"
},
*/


extension Array {
	func each(fn: (T) -> ()) {
		for i in self {
			fn(i)
		}
	}
	
	func find(fn: (T) -> Bool) -> T[] {
		var to = T[]()
		for x in self {
			let t = x as T
			if fn(t) {
				to += t
				
			}
		}
		return to
	}
	
	func find(fn: (T, Int) -> Bool) -> T[] {
		var to = T[]()
		var i = 0
		for x in self {
			let t = x as T
			if fn(t, i++) {
				to += t
			}
		}
		return to
	}
	
	func firstWhere(fn: (T) -> Bool) -> T? {
		for x in self {
			if fn(x) {
				return x
			}
		}
		return nil
	}
}