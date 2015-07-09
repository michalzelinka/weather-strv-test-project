//
//  ForecastViewCell.swift
//  
//
//  Created by Michal on 09/07/2015.
//
//

import UIKit

class DestinationsViewCell: UITableViewCell {

	@IBOutlet weak var conditionImage: UIImageView?
	@IBOutlet weak var destinationLabel: UILabel?
	@IBOutlet weak var navigationFlag: UIImageView?
	@IBOutlet weak var conditionLabel: UILabel?
	@IBOutlet weak var temperatureLabel: UILabel?

    override func awakeFromNib()
	{
        super.awakeFromNib()
		self.selectionStyle = .Default
    }

	func update(destination: Destination?, record: WeatherRecord?) -> Void
	{
		var conditionImageName = "condition-unknown"
		var temperatureString = "–"

		if var record = record
		{
			let unit = UserSettings.sharedSettings.temperatureUnit
			conditionImageName = String("condition-"+record.conditionImagePattern())
			temperatureString = NumberFormatter.double(record.temperature, toTemperatureStringWithUnit: unit, unitDisplayed: false) ?? "–"
		}

		destinationLabel?.text = destination?.name
		navigationFlag?.hidden = destination !== WeatherManager.sharedManager.locatedDestination
		conditionImage?.image = UIImage(named: conditionImageName)
		conditionLabel?.text = record?.conditionText ?? "Unknown"
		temperatureLabel?.text = temperatureString
	}

}
