//
//  LocationsStorage.swift
//  GeolocationTest
//
//  Created by Lucas Lombard on 20/08/2019.
//  Copyright © 2019 Lucas Lombard. All rights reserved.
//

import Foundation
import CoreLocation

class LocationsStorage {

  // MARK: - Properties
  static let shared = LocationsStorage()
  private(set) var locations: [Location]
  private let fileManager: FileManager
  private let documentsURL: URL

  // MARK: - Initialization
  init() {
    let fileManager = FileManager.default
    documentsURL = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    self.fileManager = fileManager
    let jsonDecoder = JSONDecoder()
    // MARK: - Get URL of all files in Documents folder
    let locationFilesURLs = try! fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
    locations = locationFilesURLs.compactMap { url -> Location? in
      // MARK: - Skipe this file
      guard !url.absoluteString.contains(".DS_Store") else {return nil}
      // MARK: - Read data from this file
      guard let data = try? Data(contentsOf: url) else {return nil}
      // MARK: - Decode raw data
      return try? jsonDecoder.decode(Location.self, from: data)
      // MARK: - Sort location by date
      }.sorted(by: { $0.date < $1.date })
  }

  // MARK: - Methodes
  func saveLocationOnDisk(_ location: Location) {
    // MARK: - Creat encoder
    let encoder = JSONEncoder()
    let timestamp = location.date.timeIntervalSince1970
    // MARK: - Get the file URL
    let fileURL = documentsURL.appendingPathComponent("\(timestamp)")
    // MARK: - Convert location to raw data
    let data = try! encoder.encode(location)
    // MARK: - Write data to the file
    try! data.write(to: fileURL)
    // MARK: - Add to the local array
    locations.append(location)
    NotificationCenter.default.post(name: .newLocationSaved, object: self, userInfo: ["location": location])
  }
  func saveCLLocationToDisk(_ clLocation: CLLocation) {
    let currentDate = Date()
    AppDelegate.geoCoder.reverseGeocodeLocation(clLocation) { placemarks, _ in
      if let place = placemarks?.first {
        let location = Location(clLocation.coordinate, date: currentDate, descriptionString: "\(place)")
        self.saveLocationOnDisk(location)
      }
    }
  }
}

extension Notification.Name {
  static let newLocationSaved = Notification.Name("newLocationSaved")
}
