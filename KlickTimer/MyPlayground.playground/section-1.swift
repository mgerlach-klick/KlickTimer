// Playground - noun: a place where people can play

import Foundation

let nsd : NSDictionary = [
	"a":"aaaa",
	"b":42,
	"GroupName":"OpenForMe"
]

let nsd2 : NSDictionary = [
	"a":"asdf",
	"b":23,
	"GroupName":"OpenFromMe"
]

let nsa : NSArray = [nsd2, nsd2, nsd]

nsd
nsd as Dictionary
nsa.valueForKey("a")
let n = nsa as AnyObject[]


let openTicketsP : NSArray = nsa.filteredArrayUsingPredicate(NSPredicate(format: "SELF.GroupName == 'OpenForMe'"))
openTicketsP