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
	var activeTicket: Ticket?
	var ticketsBySection: Dictionary<String, Ticket[]>?
}

class Ticket {
	var title:String?, ticketID:Int?, projectName:String?
	
	init (jsonModel: NSDictionary ) {
		title = jsonModel["Title"] as String!
		ticketID = jsonModel["TicketID"] as Int!
		projectName = jsonModel["ProjectName"] as String!
	}
	
	class func getAllTickets (completionBlock : (Array<NSDictionary>) -> Void){
		let ticketURL = "http://genome.klick.com:80/api/Ticket.json?ForGrid=true"
		
		let session = NSURLSession.sharedSession()
		
		let ticketDataTask = session.dataTaskWithURL(NSURL.URLWithString(ticketURL), completionHandler: {
			data, urlresponse, error in
			
			let httpResp = urlresponse as NSHTTPURLResponse
			let jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as NSDictionary
			
			let entries: NSArray = jsonResult["Entries"] as NSArray
			
			/*
			for entry : AnyObject in entries {
				let ticket = entry as NSDictionary
				
			}
			*/
			
			let results = entries as Array
			
			completionBlock(results as Array)
		})
		
		ticketDataTask.resume()
	}
}

func createOpenTicketList (fromTicketArray tickets: Array<NSDictionary>) -> TicketList {
	let openProjects : NSArray = (tickets as Array).filter { $0["GroupName"] as String == "OpenForMe" }
	let projectNames : Array = openProjects.valueForKeyPath("@distinctUnionOfObjects.ProjectName") as NSArray as Array
	var ticketsBySection: Dictionary = Dictionary<String, Ticket[]>()
	
	let ticketArray : Array = tickets.map {
		entry -> Ticket in
		let jsonDict = entry as NSDictionary
		let ticket = Ticket(jsonModel: jsonDict as NSDictionary)
		return ticket
	}
	
	for project : AnyObject in openProjects {
		let projectName = project as String
//		if ticketsBySection[projectName] == nil{
//			ticketsBySection[projectName] = Array()
//		}
		
		ticketsBySection[projectName] = ticketArray.filter {
			ticket in
			return ticket.projectName == projectName
		}
		
	}
	
	
	return TicketList(activeTicket: nil, ticketsBySection: nil)
	
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