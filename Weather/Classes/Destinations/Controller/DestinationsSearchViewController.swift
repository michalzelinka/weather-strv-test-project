//
//  DestinationsSearchViewController.swift
//  Weather
//
//  Created by Michi on 9/7/15.
//  Copyright (c) 2015 Michi. All rights reserved.
//

import UIKit


// MARK: - Controller delegate -

protocol DestinationsSearchViewControllerDelegate: NSObjectProtocol
{
	func destinationsSearchViewControllerDidSelectDestination(destination: Destination)
	func destinationsSearchViewControllerDidFinish()
}


// MARK: - Controller -

class DestinationsSearchViewController: UITableViewController,
                                        UITextFieldDelegate,
                                        UISearchBarDelegate
{

	@IBOutlet weak var searchBar : UISearchBar!

	var delegate: DestinationsSearchViewControllerDelegate?
	var foundDestinations: [Destination]?


	// MARK: - View lifecycle
	
	override func viewDidLoad()
	{
		super.viewDidLoad()

		// Search bar appearance changes

		searchBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
		searchBar.delegate = self

		let searchField = searchBar.viewForClass(UITextField) as? UITextField
		let searchFieldBackground = searchField?.subviews.first as? UIView
		searchFieldBackground?.hidden = true
		searchField?.layer.borderWidth = (UIScreen.mainScreen().scale > 1) ? 0.8 : 1
		searchField?.layer.cornerRadius = 5.0
		searchField?.layer.borderColor = Colors.defaultBlue().CGColor
		searchField?.keyboardType = .WebSearch
		searchField?.returnKeyType = .Search
	}

	override func viewDidAppear(animated: Bool)
	{
		// Set as first responder on appearing
		super.viewDidAppear(animated)
		searchBar.becomeFirstResponder()
	}

	override func viewWillDisappear(animated: Bool)
	{
		// Resign as first responder on dismissing
		super.viewWillDisappear(animated)
		searchBar.resignFirstResponder()
	}


	// MARK: - Actions

	@IBAction func closeButtonTapped(sender: UIControl)
	{
		self.resignFirstResponder()
		delegate?.destinationsSearchViewControllerDidFinish()
	}


	// MARK: - Table view delegate

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return foundDestinations?.count ?? 0
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		let destination = foundDestinations?[indexPath.row]

		let cell = tableView.dequeueReusableCellWithIdentifier("DestinationsSearchViewCell") as! UITableViewCell

		// Construct Destination title to display in cell

		var titleComponents = [String]()

		if (destination?.name?.length() > 0) { titleComponents.append(destination!.name!) }
		if (destination?.country?.length() > 0) { titleComponents.append(destination!.country!) }

		var title = ", ".join(titleComponents) ?? "Unknown"

		var ms = NSMutableAttributedString(string: title, attributes: [
			NSForegroundColorAttributeName: Colors.fromRGB(0x333333, alphaValue: 1.0),
			NSFontAttributeName: UIFont.lightSystemFontOfSize(cell.textLabel!.font.pointSize)
		])

		if let range = title.rangeOfString(",",
			options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil)
		{
			let start = 0
			let length = distance(title.startIndex, range.startIndex)
			let nsRange = NSMakeRange(start, length)
			ms.addAttribute(NSFontAttributeName, value: cell.textLabel!.font, range: nsRange)
		}

		cell.textLabel?.attributedText = ms

		return cell
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		tableView.deselectRowAtIndexPath(indexPath, animated: true)

		if let destination = foundDestinations?[indexPath.row] {

			// Check following state of Destination, notify or add if possible

			if (contains(WeatherManager.sharedManager.followedDestinations, destination)) {
				SVProgressHUD.showInfoWithStatus("Destination is already followed")
			} else {
				delegate?.destinationsSearchViewControllerDidSelectDestination(destination)
			}
		}
	}
	
	override func scrollViewWillBeginDragging(scrollView: UIScrollView)
	{
		// Resign as first responder when scrolling through the list
		searchBar.resignFirstResponder()
	}


	// MARK: - Screen refreshing

	func reloadData() -> Void
	{
		tableView.reloadData()
	}


	// MARK: - Search Bar delegate

	func searchBarSearchButtonClicked(searchBar: UISearchBar)
	{
		searchBar.resignFirstResponder()

		SVProgressHUD.showWithStatus("Searching locations…")

		WeatherManager.sharedManager.searchForWeatherLocations(searchBar.text, completion: { (destinations) -> Void in

			self.foundDestinations = destinations

			// Refresh on main thread
			dispatch_async(dispatch_get_main_queue()) {() -> Void in

				// Notify or dismiss HUD
				if (self.foundDestinations?.count == 0)
				{ SVProgressHUD.showErrorWithStatus("No destinations found") }
				else { SVProgressHUD.dismiss() }

				// Reload table data
				self.reloadData()
			}

		})
	}

	func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
	{
		// Reset table contents when search bar text changes
		self.foundDestinations = [ ]
		self.reloadData()
	}
}