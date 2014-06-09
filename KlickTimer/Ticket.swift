//
//  Ticket.swift
//  KlickTimer
//
//  Created by Max Gerlach on 2014-06-09.
//  Copyright (c) 2014 Klick Health. All rights reserved.
//

import Foundation
import Swift

class Ticket {
	
	struct TicketList {
		var ticketsBySection: Dictionary<String, Ticket[]>
		var activeTicket: Ticket
	}
	
	class func getAllTickets (#completionBlock : (Array<Ticket>) -> Void) {
		let ticketURL = "http://genome.klick.com:80/api/Ticket.json?ForGrid=true"
		
		let session = NSURLSession.sharedSession()
		
		let ticketDataTask = session.dataTaskWithURL(NSURL.URLWithString(ticketURL), completionHandler: {
			data, urlresponse, error in
			
			let httpResp = urlresponse as NSHTTPURLResponse
			let jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as NSDictionary
			
//			println(jsonResult)

			let results: NSArray = jsonResult["Entries"] as NSArray

			let openProjects : NSArray = (results as Array).filter { $0["GroupName"] as String == "OpenForMe" }
			let projectNames : Array = openProjects.valueForKeyPath("@distinctUnionOfObjects.ProjectName") as NSArray as Array
			let groupNames : Array = results.valueForKeyPath("@distinctUnionOfObjects.GroupName") as NSArray! as Array

			// Swift won't let me downcast this directly, i have to force it this way. http://stackoverflow.com/questions/24091370/annotation-error-in-swift-for-loop-with-array-and-uiview
			for result: AnyObject in results {
				let r = result as NSDictionary as Dictionary
				println(r)
			}

			/*
			dispatch_async(dispatch_get_main_queue()) {
				if !error && httpResp.statusCode == 200 {
					self.cleanup()
					callback(true)
				} else {
					callback(false)
				}
			}*/
		})
		
		ticketDataTask.resume()
	}
}