//
//  WeatherManager.swift
//  
//
//  Created by Michal on 07/07/2015.
//
//
//  FILE TODO:
//  - Group URL - http://api.openweathermap.org/data/2.5/group?id=524901,703448,2643743
//

import UIKit

class WeatherManager: NSObject {

	var locatedDestination: Destination?
	var selectedDestination: Destination?
	var followedDestinations = [Destination]()
	var requestsQueue: NSOperationQueue

	var weatherRecordsCache = [Int: [WeatherRecord]]()

	class var sharedManager: WeatherManager
	{
		struct Singleton { static let shared = WeatherManager() }
		return Singleton.shared;
	}

	override init()
	{
		requestsQueue = NSOperationQueue()
		requestsQueue.name = "Weather queue"
		requestsQueue.maxConcurrentOperationCount = 4

		super.init()
	}


	// MARK: - Temporary cache workers

	func cachedRecords(destination: Destination?) -> [WeatherRecord]?
	{
		if let destination = destination {
			return weatherRecordsCache[destination.identifier!]
		}

		return nil
	}

	func cacheRecords(records: [WeatherRecord]?, destination: Destination?) -> Void
	{
		if let d = destination {
			if let r = records {
				weatherRecordsCache[d.identifier!] = r
			}
		}
	}


	// MARK: - Data fetching workers

	func weatherForDestination(destination: Destination?,
		completion: ((records: [WeatherRecord]?) -> Void)?) -> Void
	{
		// Return empty result when no Destination given

		if (destination == nil) { completion?(records: nil); return }

		// Return cached values if available

		if let cached = self.cachedRecords(destination)
		{
			completion?(records: cached)
			return
		}

		// Fetch online data for the given Destination

		let urlString = String(format: "http://api.openweathermap.org/data/2.5/forecast/daily?id=%d&cnt=14",
			destination!.identifier!)

		let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
		request.timeoutInterval = 5.0

		NSURLConnection.sendAsynchronousRequest(request, queue: requestsQueue)
		{ (response, data, error) -> Void in

			if (error != nil) {
				NSLog("Request error")
				completion?(records: nil)
				return
			}

			// Parse JSON
			let json = JSON(data: data)

			// Parse Destination
			let city = json["city"]
			let destination = Destination(json: city)

			// Parse Weather records
			let entries = json["list"].array ?? [ ]
			var records: [WeatherRecord] = [ ]

			for e in entries
			{
				var record = WeatherRecord(json: e)
				records.append(record)
			}

			// Cache records
			self.cacheRecords(records, destination: destination)

			// Call back
			completion?(records: records)
				
		}
	}

	func weatherForCurrentLocation(completion: ((destination: Destination?, records: [WeatherRecord]?) -> Void)?) -> Void
	{
		// Return empty result when Location access not authorised

		if (LocationManager.sharedManager.checkAuthorisation() != true)
		{
			completion?(destination: nil, records: nil)
			return
		}

		// Return cached values if available

		if let cached = self.cachedRecords(locatedDestination)
		{
			completion?(destination: locatedDestination!, records: cached)
			return
		}

		// Fetch online data if user's location is available

		if let location = LocationManager.sharedManager.lastLocation
		{
			let urlString = String(format: "http://api.openweathermap.org/data/2.5/forecast/daily?lat=%.5f&lon=%.5f&cnt=14",
				location.coordinate.latitude, location.coordinate.longitude)

			let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
			request.timeoutInterval = 5.0

			NSURLConnection.sendAsynchronousRequest(request, queue: requestsQueue)
			{ (response, data, error) -> Void in

				if (error != nil) {
					NSLog("Request error")
					completion?(destination: nil, records: nil)
					return
				}

				// Parse JSON
				let json = JSON(data: data)

				// Parse Destination
				let city = json["city"]
				let destination = Destination(json: city)

				// Parse Wether records
				let entries = json["list"].array ?? [ ]
				var records: [WeatherRecord] = [ ]

				for e in entries
				{
					var record = WeatherRecord(json: e)
					records.append(record)
				}

				// Assign and cache records
				self.locatedDestination = destination
				self.cacheRecords(records, destination: destination)

				// Call back
				completion?(destination: destination, records: records)

			}
		}

		// Otherwise return empty result

		else { completion?(destination: nil, records: nil) }
	}

	func searchForWeatherLocations(query: String?, completion: ((destinations: [Destination]?) -> Void)?) -> Void
	{
		// Return empty result when search term is too short

		if (query?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) < 3)
		{ completion?(destinations: nil) }

		// Call API for results with the given query

		let urlString = String(format: "http://api.openweathermap.org/data/2.5/find?q=%@&type=like",
			query!.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)

		let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
		request.timeoutInterval = 5.0

		NSURLConnection.sendAsynchronousRequest(request, queue: requestsQueue)
		{ (response, data, error) -> Void in

			if (error != nil) {
				NSLog("Request error")
				completion?(destinations: nil)
				return
			}

			// Parse JSON
			let json = JSON(data: data)

			// Parse Destinations
			let cities = json["list"].array ?? [ ]
			var destinations: [Destination] = [ ]

			for c in cities
			{
				var dest = Destination(json: c)
				destinations.append(dest)
			}

			// Call back
			completion?(destinations: destinations)

		}
	}

}
