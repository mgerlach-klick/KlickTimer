//
//  ViewController.swift
//  KlickTimer
//
//  Created by Max Gerlach on 2014-06-09.
//  Copyright (c) 2014 Klick Health. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
                            
	override func viewDidLoad() {
		super.viewDidLoad()
		
		GenomeAuthenticator(presentingViewController: self).authenticate {
			println("You are now authenticated!")
			Ticket.getAllTickets {
				tickets in
				println("You should now have all tickets")
				createOpenTicketList(fromTicketArray: tickets)
			}
		}
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

