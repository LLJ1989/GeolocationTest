//
//  MapViewController.swift
//  GeolocationTest
//
//  Created by Lucas Lombard on 20/08/2019.
//  Copyright © 2019 Lucas Lombard. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

  // MARK: - Outlets
  @IBOutlet weak var mapView: MKMapView!

  // MARK: - Methodes
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.userTrackingMode = .follow
    let annotations = LocationsStorage.shared.locations.map { annotationForLocation($0) }
    mapView.addAnnotations(annotations)
    NotificationCenter.default.addObserver(self, selector: #selector(newLocationAdded(_:)), name: .newLocationSaved, object: nil)
  }
  func annotationForLocation(_ location: Location) -> MKAnnotation {
    let annotation = MKPointAnnotation()
    annotation.title = location.dateString
    annotation.coordinate = location.coordinates
    return annotation
  }
  @objc func newLocationAdded(_ notification: Notification) {
    guard let location = notification.userInfo?["location"] as? Location else {return}
    let annotation = annotationForLocation(location)
    mapView.addAnnotation(annotation)
  }

  // MARK: - Actions
  @IBAction func addItemPressed(_ sender: Any) {
    guard let currentLocation = mapView.userLocation.location else {return}
    LocationsStorage.shared.saveCLLocationToDisk(currentLocation)
  }

}
