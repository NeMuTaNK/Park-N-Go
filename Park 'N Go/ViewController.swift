//
//  ViewController.swift
//  Park 'N Go
//
//  Created by Shaheen Sharifian on 7/3/15.
//  Copyright (c) 2015 Shaheen Sharifian. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

var carInitialCoordinate:CLLocationCoordinate2D!
var carInitialLocation: CLLocation!
var completeAddress:NSString = "";
var manager = CLLocationManager();

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UIAlertViewDelegate {
    
    @IBOutlet var map: MKMapView!
    @IBOutlet var pinLocationButton: UIButton!
        
    var currentLocation:MKUserLocation!;
    var isPinLocationButtonPressed = false;

    var isEmpty = false;
    let regionRadius: CLLocationDistance = 1000
   
    override func viewDidLoad() {
        
        super.viewDidLoad()
        if(NSUserDefaults.standardUserDefaults().objectForKey("pinnedLocation") != nil) {
            pinLocationButton.enabled = false;
        }
        if let loadedData = NSUserDefaults.standardUserDefaults().dataForKey("pinnedLocation") {
            if let loadedLocation = NSKeyedUnarchiver.unarchiveObjectWithData(loadedData) as? CLLocation {
                println(loadedLocation.coordinate.latitude)
                println(loadedLocation.coordinate.longitude)
                getLocationInfo(loadedLocation);
            }
        }
        
        map.delegate = self;
        manager.delegate = self;
        manager.desiredAccuracy = kCLLocationAccuracyBest;
        manager.requestWhenInUseAuthorization();
        manager.startUpdatingLocation();
        self.map.showsUserLocation = true;
        currentLocation = map.userLocation;
    }

    @IBAction func trashButtonSelected(sender: AnyObject) {
        // Remove from NSDefaults
        // Show alertview
        let alertController = UIAlertController(title: "Are you Sure?", message: "Do you wish to delete your pinned Location?", preferredStyle: .ActionSheet);
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (Action) in
            // Cancel
        }
        let deleteButton = UIAlertAction(title: "Delete", style: .Destructive) { (Action) in
            NSUserDefaults.standardUserDefaults().removeObjectForKey("pinnedLocation");
            NSNotificationCenter.defaultCenter().postNotificationName("reloadData", object: nil);
            self.map.removeAnnotations(self.map.annotations);
            self.pinLocationButton.enabled = true;
        }
        alertController.addAction(deleteButton);
        alertController.addAction(cancelAction);
        self.presentViewController(alertController, animated: true, completion: nil);
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        // Find location of user
        var userLocation:CLLocation = locations[0] as! CLLocation;
        userLocationCoordinate = userLocation.coordinate
        var latitude = userLocation.coordinate.latitude
        var longitude = userLocation.coordinate.longitude
        var latDelta:CLLocationDegrees = 0.01
        var longDelta: CLLocationDegrees = 0.01
        var span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        var location:MKUserLocation = currentLocation;
        var region: MKCoordinateRegion = MKCoordinateRegionMake(location.coordinate, span)
        var coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude);
        carInitialLocation = userLocation;
        carInitialCoordinate = coordinate;
        
        self.map.setRegion(region, animated: true);
    }
    @IBAction func pinLocationButton(sender: AnyObject) {
        // add location to the array, so it can be retrieved and put it into temporary storage
        //places.append(["name":title,"lat":"\(newCoordinate.latitude)","lon":"\(newCoordinate.longitude)"])
        isPinLocationButtonPressed = true;
        pinLocationButton.enabled = false;
        getLocationInfo(map.userLocation.location);
        let pinnedLocation = map.userLocation.location;
        let locationData = NSKeyedArchiver.archivedDataWithRootObject(pinnedLocation);
        NSUserDefaults.standardUserDefaults().setObject(locationData, forKey: "pinnedLocation");
        NSNotificationCenter.defaultCenter().postNotificationName("loadData", object: nil);

    }
    func getLocationInfo(locationParameter:CLLocation) {
        
        var location = locationParameter
        var coordinate = location.coordinate
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            var title = ""
            if (error == nil) {
                if let p = CLPlacemark(placemark: placemarks?[0] as! CLPlacemark) {
                    
                    var subThoroughfare:String = ""
                    var thoroughfare:String = ""
                    
                    if p.subThoroughfare != nil {
                        
                        subThoroughfare = p.subThoroughfare
                    }
                    if p.thoroughfare != nil {
                        
                        thoroughfare = p.thoroughfare
                        
                    }
                    completeAddress = self.displayLocationInfo(p);
                    title = "\(subThoroughfare) \(thoroughfare)"
                }
            }
            // annotation, i.e pins
            
            var annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = title
            self.map.addAnnotation(annotation)
        })
    }
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error: " + error.localizedDescription);
    }
    
    func displayLocationInfo(placemark: CLPlacemark) -> String{
        //self.manager.stopUpdatingLocation();
        println(placemark.subThoroughfare);
        println(placemark.thoroughfare);
        println(placemark.locality);
        println(placemark.postalCode);
        println(placemark.administrativeArea);
        println(placemark.country);
        var title = "\(placemark.locality) \(placemark.postalCode) \(placemark.administrativeArea) \(placemark.country)";
        return title;
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "detailViewSegue") {
            var svc = segue.destinationViewController as! detailViewController;
            svc.toPass = title;
        }
    }
    
    
}

