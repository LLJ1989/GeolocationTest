//
//  PlacesTableViewController.swift
//  GeolocationTest
//
//  Created by Lucas Lombard on 20/08/2019.
//  Copyright © 2019 Lucas Lombard. All rights reserved.
//

import UIKit
import UserNotifications

class PlacesTableViewController: UITableViewController {

  // MARK: - Methodes
  override func viewDidLoad() {
    super.viewDidLoad()
    // MARK: - Register methode when notif arrives
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(newLocationAdded(_:)),
      name: .newLocationSaved,
      object: nil)
  }
  // MARK: - Receive the notification as a parameter
  @objc func newLocationAdded(_ notification: Notification) {
    // MARK: - Reload list
    tableView.reloadData()
  }
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return LocationsStorage.shared.locations.count
  }
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)
    let location = LocationsStorage.shared.locations[indexPath.row]
    cell.textLabel?.numberOfLines = 6
    cell.textLabel?.text = location.description
    cell.detailTextLabel?.text = location.dateString
    return cell
  }
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 110
  }
}
