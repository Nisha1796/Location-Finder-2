//
//  ViewController.swift
//  Location Finder
//
//  Created by Nisha Gohil on 2021-03-25.
//

import UIKit
import MapKit
import CoreLocation




class ViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate, MKMapViewDelegate {

   
  
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func searchbtn(_ sender: Any) {
        
        //call a method
        getAddress()
        
        
        //Indicate the running activity *
        let activityIndicator = UIActivityIndicatorView()
                activityIndicator.style  = UIActivityIndicatorView.Style.medium
                activityIndicator.center = self.view.center
                activityIndicator.hidesWhenStopped = true
                activityIndicator.startAnimating()
                self.view.addSubview(activityIndicator)

        //Create a search request
        let searchRequest = MKLocalSearch.Request()
                searchRequest.naturalLanguageQuery  = address.text
                let activeSearch = MKLocalSearch(request: searchRequest)
                
        //create response and error conditions
                activeSearch.start { (response, error) in
                    activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
               
                   
                   if response == nil {
                   print("Error!")
                   }
                   else {
                       let annotations = self.mapView.annotations
                       self.mapView.removeAnnotations(annotations)
                       
                       let latitude = response?.boundingRegion.center.latitude
                       let longitude = response?.boundingRegion.center.longitude
                       
                       let annotation = MKPointAnnotation()
                       annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                       self.mapView.addAnnotation(annotation)
                       annotation.title = "YOU DESTINATION"
                       
                   }
    }
        
        
        
        if (address.text != nil) {
          
            array.append(address.text!)
        }
        ViewController.load()
        reloadInputViews()
        
                }
    
    

    //Define location manager
    let locationManager = CLLocationManager()
   
    //Get address from text field input
    func getAddress() {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address.text!) { (placeMark, error) in
            guard let placeMark = placeMark, let location = placeMark.first?.location
            else {
                print("No location found!")
                return
            }
            print(location)
            self.mapThis(destinationCord: location.coordinate)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup authentication, delegates, accuracy, filters
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        mapView.delegate = self
        
    }

    //Show user's currents loaction
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        
        let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        
    }
    
    //Shows destination location acccording to user's input and coordinates
    func mapThis(destinationCord: CLLocationCoordinate2D) {
        
        let sourceCordinate = (locationManager.location?.coordinate)!
        let sourcePlaceMark = MKPlacemark(coordinate: sourceCordinate)
        let destPlaceMark = MKPlacemark(coordinate: destinationCord)
        let sourceItem = MKMapItem(placemark: sourcePlaceMark)
        let destItem = MKMapItem(placemark: destPlaceMark)
        
        //create destination request
        let destinationRequest = MKDirections.Request()
        destinationRequest.source = sourceItem
        destinationRequest.destination = destItem
        destinationRequest.transportType = .automobile
        destinationRequest.requestsAlternateRoutes = true
        
        let direction = MKDirections(request: destinationRequest)
        direction.calculate { (response, error) in
            guard  let response = response
            else {
                if let error = error {
                    print("ERROR!")
                }
                return
            }
            
            let rout = response.routes[0]
            self.mapView.addOverlay(rout.polyline)
            self.mapView.setVisibleMapRect(rout.polyline.boundingMapRect, animated: true)
        }
        
    }
    
    //display direction from user's current location to destination 
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as MKOverlay)
        render.strokeColor = .green
        return render
    }
    
}

