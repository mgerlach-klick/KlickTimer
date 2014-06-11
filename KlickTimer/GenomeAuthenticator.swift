//
//  GenomeAuthenticator.swift
//  KlickTimer
//
//  Created by Max Gerlach on 2014-06-09.
//  Copyright (c) 2014 Klick Health. All rights reserved.
//

import Foundation
import UIKit


class GenomeAuthenticator : UIViewController, UIWebViewDelegate {
	
	let kGenomeLoginURL = "https://genome.klick.com/home/"
	let kConnectionTestURL = "http://genome.klick.com/api/User/3438.json" //agoldstein
	
	var completionBlock : () -> ()
	let presentingVC: UIViewController
	var presentationStyle: UIModalTransitionStyle = .PartialCurl
	
	init(presentingViewController: UIViewController) {
		self.completionBlock = {}
		self.presentingVC = presentingViewController
		
		super.init(nibName: nil, bundle: nil)
		
//		self.modalTransitionStyle = presentationStyle

	}
	
	func authenticate(completionBlock: () -> Void) {
		self.completionBlock = completionBlock

		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		
		testCookieValidity { cookieIsValid in
			if cookieIsValid {
				self.completionBlock()
			} else {
				self.presentingVC.presentModalViewController(self, animated: true)
			}
		}

	}
	
	func testCookieValidity(callback:(Bool)->Void) {
		let session = NSURLSession.sharedSession()
		
		let dataTask = session.dataTaskWithURL(NSURL.URLWithString(kConnectionTestURL), completionHandler: {
			data, urlresponse, error in
			let httpResp = urlresponse as NSHTTPURLResponse
			
			dispatch_async(dispatch_get_main_queue()) {
				if !error && httpResp.statusCode == 200 {
					self.cleanup()
					callback(true)
				} else {
					callback(false)
				}
			}
		})
		
		dataTask.resume()
	}
	
	
	override func loadView() {
		let webview = UIWebView(frame: UIScreen.mainScreen().bounds)
		webview.userInteractionEnabled = true
		webview.delegate = self
		view = webview
		
		webview.loadRequest(NSURLRequest(URL: NSURL(string: kGenomeLoginURL)))
	}
	
	func cleanup () {
		dismissModalViewControllerAnimated(true)
		UIApplication.sharedApplication().networkActivityIndicatorVisible = false
	}
	
	// MARK: UIWebView Delegate
	func webViewDidFinishLoad(webView: UIWebView!) {
		let currentURL = webView.request.URL.absoluteURL
		let genomeHost = NSURL(string: kGenomeLoginURL).host
		if currentURL.host == genomeHost {
			cleanup()
			completionBlock()
		}
	}
	
	func webViewDidFailLoadWithError (webView: UIWebView!) {
		// TODO: Do something!
	}
}


