//
//  TicketListTableViewController.swift
//  KlickTimer
//
//  Created by Max Gerlach on 2014-06-13.
//  Copyright (c) 2014 Klick Health. All rights reserved.
//

import UIKit

class TicketCell : UITableViewCell {
	@IBOutlet var ticketLabel : UILabel
	@IBOutlet var button : UIButton
	weak var ticket: Ticket?
	weak var tableView : UITableView?
	
	@IBAction func button(sender : AnyObject) {
//		TicketList.activeTicket = ticket!
		ticket!.toggleTracking()
		tableView!.reloadData()
	}
	
}

class TicketListTableViewController: UITableViewController {
	
	var ticketList : TicketList?
	var ticketSectionArray : String[]?


    override func viewDidLoad() {
        super.viewDidLoad()

		refreshTicketList()

		refreshControl = UIRefreshControl()
		refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
		refreshControl.addTarget(self, action: "refreshTicketList", forControlEvents: .ValueChanged)
    }
	
	func refreshTicketList () {
		println("Now authenticating")
		GenomeAuthenticator(presentingViewController: self).authenticate {
			
			println("You are now authenticated!")
			if self.refreshControl { self.refreshControl.attributedTitle = NSAttributedString(string: "Refreshing Ticket List") }
			
			Ticket.getAllTickets { tickets
				in
				
				println("Got all tickets!")
				self.ticketList = createOpenTicketList(fromTicketArray: tickets)
				if let keys = self.ticketList!.ticketsBySection?.keys {
					self.ticketSectionArray = Array(keys) // as per https://developer.apple.com/library/prerelease/ios/documentation/General/Reference/SwiftStandardLibraryReference/Dictionary.html
				}
				
				NSOperationQueue.mainQueue().addOperationWithBlock{() in
					self.tableView.reloadData()
					if self.refreshControl.refreshing {
						self.refreshControl.endRefreshing()
					}
				}
				
			}
		}
	}


	// MARK:  - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {

		if let numberOfSections = self.ticketSectionArray?.count {
			return numberOfSections
		} else {
			return 0
		}
	}

    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
		let sectionName = ticketSectionArray![section]
		
		if let numberOfRows = ticketList!.ticketsBySection![sectionName]?.count {
			return numberOfRows
		} else {
			return 0
		}
    }

	override func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
		if let sectionName = ticketSectionArray?[section] {
			return sectionName
		}
		return ""
	}

    override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
		let cell : TicketCell = tableView!.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as TicketCell

		// Configure the cell...
		let sectionName = ticketSectionArray![indexPath!.section]
		let section = ticketList!.ticketsBySection![sectionName]!
		let ticket = section[indexPath!.row]
		
		if ticket == TicketList.activeTicket {
			cell.button.backgroundColor = UIColor.redColor()
			cell.button.setTitle("STOP", forState: .Normal)
		} else {
			cell.button.backgroundColor = UIColor.greenColor()
			cell.button.setTitle("Track", forState: .Normal)

		}
		
		cell.ticketLabel.text = ticket.title

		cell.tableView = tableView
		cell.ticket = ticket
		
        return cell
    }
	



    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
