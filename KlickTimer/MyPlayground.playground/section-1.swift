// Playground - noun: a place where people can play

import Foundation

let kGenomeLoginURL = "https://genome.klick.com/home/"
let kConnectionTestURL = "http://genome.klick.com/api/User/3438.json" //agoldstein

func testCookieValidity(callback: (Bool) -> Void) -> Void {
	let session = NSURLSession.sharedSession()
	
	let dataTask = session.dataTaskWithURL(NSURL.URLWithString(kConnectionTestURL), completionHandler:
		{
			data, urlresponse, error in
			let httpResp = urlresponse as NSHTTPURLResponse
			println(httpResp)
			
			if !error && httpResp.statusCode == 200 {
				callback(true)
			} else {
				callback(false)
			}
		})
	
	dataTask.resume()
}

testCookieValidity {
	cookieIsValid in
	cookieIsValid
	println("Bookie is valid: \(cookieIsValid)")
}
	