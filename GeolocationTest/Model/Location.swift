//
//  Location.swift
//  GeolocationTest
//
//  Created by Lucas Lombard on 20/08/2019.
//  Copyright © 2019 Lucas Lombard. All rights reserved.
//

import Foundation
import CoreLocation

class Location: Codable {

  // MARK: - Properties
  static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .medium
    return formatter
  }()
  var coordinates: CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
  let latitude: Double
  let longitude: Double
  let date: Date
  let dateString: String
  let description: String

  // MARK: - Initialization
  init(_ location: CLLocationCoordinate2D, date: Date, descriptionString: String) {
    latitude =  location.latitude
    longitude =  location.longitude
    self.date = date
    dateString = Location.dateFormatter.string(from: date)
    description = descriptionString
  }
  convenience init(visit: CLVisit, descriptionString: String) {
    self.init(visit.coordinate, date: visit.arrivalDate, descriptionString: descriptionString)
  }
}
