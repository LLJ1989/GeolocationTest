//
//  AppDelegate.swift
//  GeolocationTest
//
//  Created by Lucas Lombard on 20/08/2019.
//  Copyright © 2019 Lucas Lombard. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  static let geoCoder = CLGeocoder()
  let center = UNUserNotificationCenter.current()
  let locationManager = CLLocationManager()

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    center.requestAuthorization(options: [.alert, .sound]) { granted, error in
    }
    locationManager.requestAlwaysAuthorization()
    locationManager.startMonitoringVisits()
    locationManager.delegate = self
    // MARK: - Receive location updates
    //locationManager.distanceFilter = 35
    // MARK: - Allow location tracking in background
    //locationManager.allowsBackgroundLocationUpdates = true
    // MARK: - Start listening
    //locationManager.startUpdatingLocation()
    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }

}

extension AppDelegate: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
    // create CLLocation from the coordinates of CLVisit
    let clLocation = CLLocation(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude)
    AppDelegate.geoCoder.reverseGeocodeLocation(clLocation) { placemarks, _ in
      if let place = placemarks?.first {
        let description = "\(place)"
        self.newVisitReceived(visit, description: description)
      }
    }
  }
  func newVisitReceived(_ visit: CLVisit, description: String) {
    let location = Location(visit: visit, descriptionString: description)
    LocationsStorage.shared.saveLocationOnDisk(location)
    // MARK: - Creat notification content
    let content = UNMutableNotificationContent()
    content.title = "New Journal entry 📌"
    content.body = location.description
    content.sound = .default
    // MARK: - creat notification trigger
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    let request = UNNotificationRequest(identifier: location.dateString, content: content, trigger: trigger)
    // MARK: - Adding notification to notification center
    center.add(request, withCompletionHandler: nil)
  }
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    // MARK: - Discard all locations except first one
    guard let location = locations.first else {return}
    // MARK: - Grab location description
    AppDelegate.geoCoder.reverseGeocodeLocation(location) { placemarks, _ in
      if let place = placemarks?.first {
        // MARK: - Mark visit as a fake one
        let description = "Fake visit: \(place)"
        // MARK: - Creat instance of FakeVisite and pass it to newVisitReceived
        let fakeVisit = FakeVisit(
          coordinates: location.coordinate,
          arrivalDate: Date(),
          departureDate: Date())
        self.newVisitReceived(fakeVisit, description: description)
      }
    }
  }
}

final class FakeVisit: CLVisit {
  private let myCoordinates: CLLocationCoordinate2D
  private let myArrivalDate: Date
  private let myDepartureDate: Date
  override var coordinate: CLLocationCoordinate2D {
    return myCoordinates
  }
  override var arrivalDate: Date {
    return myArrivalDate
  }
  override var departureDate: Date {
    return myDepartureDate
  }

  init(coordinates: CLLocationCoordinate2D, arrivalDate: Date, departureDate: Date) {
    myCoordinates = coordinates
    myArrivalDate = arrivalDate
    myDepartureDate = departureDate
    super.init()
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
