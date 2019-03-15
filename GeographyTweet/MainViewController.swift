//
//  MainViewController.swift
//  GeographyTweet
//
//  Created by Mehrdad Ahmadi on 2019-03-03.
//  Copyright © 2019 Mehrdad Ahmadi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import DZNEmptyDataSet
import Alamofire

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate {

    // MARK: - Variables
    
    var tweets: [Tweet] = []
    var locationManager = CLLocationManager()
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
//        locationManager.delegate = self
//        locationManager.requestLocation()
        setDefaultLocation()
        getTweets()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }

    
    
    // MARK: - Methods
    
    private func setDefaultLocation() {
        let radius: CLLocationDistance = 1000
        let location = CLLocation(latitude: 45.500439, longitude: -73.568839) //lat: 45.500439 long:-73.568839
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radius, longitudinalMeters: radius)
        mapView.setRegion(region, animated: true)
    }
    
    private func getTweets() {
        if let savedTweets = HelperMethods.retrievePersistedTweets() {
            tweets = savedTweets
            tableView.reloadData()
            refreshMapView()
            return
        }
        
        let coordinates: CLLocationCoordinate2D
//        if let location = locationManager.location {
//            coordinates = location.coordinate
//        }
//        else {
            coordinates = mapView.centerCoordinate
//        }
        NetworkManager.retrieveRecentTweets(latitude: coordinates.latitude, longitude: coordinates.longitude, radius: 10) { tweets in
            
            self.tweets = tweets
            self.tableView.reloadData()
            self.refreshMapView()
        }
    }
    
    private func refreshMapView() {
        mapView.addAnnotations(tweets)
    }
    
    
    // MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    // MARK: - TableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tweet = tweets[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetTableViewCell
        cell.tweet = tweet
        let tweetLocation = tweet.place.location
        if let distance = locationManager.location?.distance(from: tweetLocation) {
            let distanceText: String
            switch distance {
            case 0..<1000:
                distanceText = "\(Int(distance))m"
            default:
                let dist = distance/1000
                distanceText = String(format: "%.3fkm", dist)
            }
            cell.distance.text = distanceText
        }
        else {
            cell.distance.text = ""
        }
        return cell
    }
    
    
    // MARK: - DZNEmptyDataSetSource
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "There's nothing here! :)")
    }

    
    // MARK: - CoreLocationManager Delegate
    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        switch status {
//        case .authorizedWhenInUse:
//            locationManager.requestLocation()
//        default:
//            let alert = UIAlertController(title: "Alert", message: "Location Access Not Permitted", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            present(alert, animated: true, completion: nil)
//        }
//    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            setDefaultLocation()
            return
        }
        let radius: CLLocationDistance = 1000
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radius, longitudinalMeters: radius)
        mapView.setRegion(region, animated: true)
//        getTweets()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error happened \(error.localizedDescription)")
        setDefaultLocation()
    }
    
    
    // MARK: - MKMapView Delegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        if let cluster = annotation as? MKClusterAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "ClusterAnnotation") as? MKMarkerAnnotationView
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: nil, reuseIdentifier: "ClusterAnnotation")
            }
            annotationView?.markerTintColor = UIColor.blue
            
            cluster.title = "\(cluster.memberAnnotations.count) tweets here"
            annotationView?.annotation = cluster
            
            return annotationView
        }
        else if let tweetMarker = annotation as? Tweet {
            var annotationMarkerView = mapView.dequeueReusableAnnotationView(withIdentifier: "TweeterAnnotation") as? MKMarkerAnnotationView
            if annotationMarkerView == nil {
                annotationMarkerView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "TweeterAnnotation")
            }
            else {
                annotationMarkerView?.annotation = tweetMarker
            }
            annotationMarkerView?.markerTintColor = UIColor(displayP3Red: 102/255.0, green: 155/255.0, blue: 91/255.0, alpha: 1)
            annotationMarkerView?.glyphText = "🐦"
            
            return annotationMarkerView
        }
        
        return nil
    }
    
    
    // MARK: - UISearchBar Delegate
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}

