//
//  AttractionsVC.swift
//  Park 'N Go
//
//  Created by Shaheen Sharifian on 7/10/15.
//  Copyright (c) 2015 Shaheen Sharifian. All rights reserved.
//

import UIKit
import MapKit
import AddressBook

var matchingItems: [MKMapItem] = [MKMapItem]();
var indicatedMapItem:CLLocationCoordinate2D!;
var userLocationCoordinate:CLLocationCoordinate2D!;

class AttractionsVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate {
    
    // For list in pinned location and attractions. To be
    var attractionDict: NSDictionary!
    var categoryDictionary = [String:[String]]();
    class func searchWithQueryWithRadius(map: MKMapView, term: String, deal: Bool, radius: Int, sort: Int, categories: String, completion: ([Resturant]!, NSError!) -> Void) {
        YelpClient.sharedInstance.searchWithTerm(term, deal: false, radius: radius, sort: sort,categories: categories, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            let responseInfo = response as! NSDictionary
            resultQueryDictionary = responseInfo
            println(responseInfo)
            let dataArray = responseInfo["businesses"] as! NSArray
            for business in dataArray {
                let obj = business as! NSDictionary
                var yelpBusinessMock: YelpBusiness = YelpBusiness(dictionary: obj)
                var annotation = MKPointAnnotation()
                annotation.coordinate = yelpBusinessMock.location.coordinate
                annotation.title = yelpBusinessMock.name
                map.addAnnotation(annotation)
            }
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println(error)
        }
    }
    @IBOutlet var searchText: UITextField!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var attractionsMap: MKMapView!
    var locationManager = CLLocationManager();
    var businessStreetAddress: CLLocationCoordinate2D!


    @IBOutlet weak var attractionsTabView: UITableView! //testVersion
    @IBOutlet weak var AttractionsTableView: UITableView!
    
    var currentArray:[String] = [String]();
    var categoriesList = ["Food", "Entertainment", "Recreation", "Shopping", "Transport", "Lodging", "Services"]
    var foodCategories = [String]();
    var entertainmentCategories = [String]();
    var recreationCategories = [String]();
    var shoppingCategories = [String]();
    var transportCategories = [String]();
    var lodgingCategories = [String]();
    var servicesCategories = [String]();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSetUps();
        attractionsMap.mapType = MKMapType.Hybrid;
        attractionsMap.delegate = self;
        locationManager.delegate = self;
        locationManager.requestWhenInUseAuthorization();
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        // Do any additional setup after loading the view.
        let location = self.locationManager.location;
        var coordinate = carInitialCoordinate
        var latitude = location.coordinate.latitude;
        var longitude = location.coordinate.longitude;
        var latDelta:CLLocationDegrees = 0.03;
        var longDelta:CLLocationDegrees = 0.03;
        
        var span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta);
        var overallLoc = CLLocationCoordinate2DMake(latitude, longitude);
        var region:MKCoordinateRegion = MKCoordinateRegionMake(overallLoc, span);
        attractionsMap.region = region;
        attractionsMap.setRegion(region, animated: true)
        self.attractionsMap.showsUserLocation = true;
    }
    func setupSetUps() {
        
        setUpCategoryEntertainment()
        setupCategoryFood();
        setUpRecreation()
        setUpShopping()
        setUpTransport()
        setUpLodging()
        setupServices()
        
    }
    
    func setupCategoryFood() {
        let asianFood = "Asian Food"
        let americanFood = "American Food"
        let bakery = "Bakery"
        let cofeehouses = "Coffee"
        let frenchFood = "French Food"
        let seafood = "Seafood"
        let steakhouses = "Steakhouse"
        let mexicanFood = "Mexican Food"
        let fastFood = "Fast Food"
        let MiddleEasternFood = "Middle Eastern Food"
        
        foodCategories.append(asianFood);
        foodCategories.append(mexicanFood);
        foodCategories.append(fastFood);
        foodCategories.append(MiddleEasternFood);
        foodCategories.append(americanFood);
        foodCategories.append(bakery);
        foodCategories.append(cofeehouses);
        foodCategories.append(seafood);
        foodCategories.append(steakhouses);

        
        categoryDictionary["Food"] = foodCategories;
    }
    func setUpCategoryEntertainment() {
        var movieTheaters = "Movie Theatre"

        entertainmentCategories.append(movieTheaters);
        
        categoryDictionary["Entertainment"] = entertainmentCategories;

    }
    func setUpRecreation() {
        var parks = "Parks"
        var beaches = "Beach"
        var amusementParks = "Amusement Park"
        
        recreationCategories.append(parks);
        recreationCategories.append(beaches);
        recreationCategories.append(amusementParks);
        
        categoryDictionary["Recreation"] = recreationCategories;

    }
    func setUpShopping() {
        var malls = "Mall";
        shoppingCategories.append(malls);
        var supermarkets = "Supermarket";
        var electronics = "Electronics";
        
        shoppingCategories.append(malls);
        shoppingCategories.append(supermarkets);
        shoppingCategories.append(electronics);
        
        categoryDictionary["Shopping"] = shoppingCategories;
    }
    func setUpTransport() {
        var busStops = "Bus Stops"
        var parknride = "Park & Ride"
        var taxis = "Taxi"
        
        transportCategories.append(busStops);
        transportCategories.append(parknride);
        transportCategories.append(taxis);
        
        categoryDictionary["Transport"] = transportCategories;

    }
    func setUpLodging() {
        var hotels = "Hotel"
        var motels = "Motel"
        var hostels = "Hostel"
        
        lodgingCategories.append(hotels);
        lodgingCategories.append(motels);
        lodgingCategories.append(hostels);
        
        categoryDictionary["Lodging"] = lodgingCategories;
    }
    func setupServices() {
        var bank = "Bank"
        var atm = "ATM"
        var postOffice = "Post Office"
        
        servicesCategories.append(bank);
        servicesCategories.append(atm);
        servicesCategories.append(postOffice);
        
        categoryDictionary["Services"] = servicesCategories;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func returnText(sender: AnyObject) {
        sender.resignFirstResponder();
        attractionsMap.removeAnnotations(attractionsMap.annotations);
        //performSearch(searchText.text);
//        Resturant.searchWithQuery(searchText.text!, completion: { (resturants : [Resturant]!, error: NSError!) -> Void in
//            if(error != nil) {
//                println(error)
//            } else {
//                self.Businesses = resturants
//                println(resturants)
//            }
//        })
//        performYelpSearchWithParams(searchText.text)
        performYelpSearch(searchText.text)
    }
    func performYelpSearch(query: String) {
        attractionsMap.removeAnnotations(attractionsMap.annotations)
        matchingItems.removeAll()

        Resturant.searchWithQuery(self.attractionsMap, query: query, completion: { (BusinessList: [Resturant]!, error: NSError!) in
            if(error != nil) {
                println("Error occured in search: \(error.localizedDescription)")
            } else if BusinessList.count == 0 {
                println("No matches found")
            } else {
                println("Yelp matches found!")
            }
        })
    }
    func performYelpSearchWithParams(query: String) {
        attractionsMap.removeAnnotations(attractionsMap.annotations)
        matchingItems.removeAll()
        Resturant.searchWithQueryWithRadius(self.attractionsMap, term: query, deal: false, radius: 100, sort: 0, categories: "Restaurants") { (BusinessList: [Resturant]!, error: NSError!) -> Void in
            if(error != nil) {
                println("Error occured in the search \(error.localizedDescription)")
            } else if BusinessList.count == 0 {
                println("No matches")
            } else {
                println("Yelp Matches Found!")
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as! CLLocation;
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude);
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(0.01, 0.01));
        self.attractionsMap.setRegion(region, animated: true);
        
        var point:MKPointAnnotation! = MKPointAnnotation();
        point.coordinate = location.coordinate;
        point.title = "Current Location";
        point.subtitle = "Subtitle";
        self.attractionsMap.addAnnotation(point);
        locationManager.stopUpdatingLocation();
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if(annotation is MKUserLocation) {
            return nil;
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView;
        if(pinView == nil) {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId);
            pinView!.canShowCallout = true;
            pinView!.animatesDrop = true;
            
        }
        var moreInfoButton = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as! UIButton;
        pinView?.rightCalloutAccessoryView = moreInfoButton;
        return pinView;
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if (control == view.rightCalloutAccessoryView) {
            let selectedLocation = view.annotation;
            let selectedCoordinate = view.annotation.coordinate;
            var latitude = selectedCoordinate.latitude
            var longitude = selectedCoordinate.longitude
            var location:CLLocation = CLLocation(latitude: latitude, longitude: longitude)
            let businessPlacemark = MKPlacemark(coordinate: selectedCoordinate, addressDictionary: nil)
            indicatedMapItem = selectedCoordinate;
            let resturantMock:Resturant = Resturant(dictionary: resultQueryDictionary)
            attractionDict = resturantMock.location;
            performSegueWithIdentifier("attractionToDetail", sender: self);
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var attractionsDetailViewController:AttractionsDetailViewController = segue.destinationViewController as! AttractionsDetailViewController
        attractionsDetailViewController.attractionLocation = indicatedMapItem;
        attractionsDetailViewController.attractionLocationDetail = self.attractionDict
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return categoriesList.count;
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?  {
        return categoriesList[section];
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var sectionTitle = categoriesList[section];
        var sectionArray = categoryDictionary[sectionTitle];
        return sectionArray!.count;
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("myCell") as! UITableViewCell;
        
        var sectionTitle = categoriesList[indexPath.section]
        var sectionArray = categoryDictionary[sectionTitle];
        var itemInArray = sectionArray?[indexPath.row];
        cell.textLabel?.text = itemInArray;
        
        return cell
    }


    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var detailView = false;
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        var sectionTitle = categoriesList[indexPath.section]
        var sectionArray = categoryDictionary[sectionTitle];
        var itemInArray = sectionArray?[indexPath.row];
        
        //performSearch(itemInArray!);
//        Resturant.searchWithQuery(itemInArray!, completion: { (resturants : [Resturant]!, error: NSError!) -> Void in
//            if(error != nil) {
//                println(error)
//            } else {
//                self.Businesses = resturants
//                println(resturants)
//            }
//        })
        performYelpSearch(itemInArray!)
//        performYelpSearchWithParams(itemInArray!)
        self.attractionsTabView.deselectRowAtIndexPath(indexPath, animated: true)
    
    }
    
}