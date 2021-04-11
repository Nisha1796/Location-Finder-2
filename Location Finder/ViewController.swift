//
//  ViewController.swift
//  Location Finder
//
//  Created by Nisha Gohil on 2021-03-25.
//

import UIKit
import MapKit
import CoreLocation
import Speech
import SQLite3
import CoreData







class ViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate, MKMapViewDelegate, SFSpeechRecognizerDelegate  {

    //initializing speech components
    @IBOutlet weak var btn_start: UIButton!
    @IBOutlet weak var lb_speech: UILabel!
  
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    let userDefaults = UserDefaults.standard
    
    @IBAction func searchbtn(_ sender: Any) {
        
        //call a method
        getAddress()
        
        //NSString * myDB=@"History2"
        
        
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
            HistoryArray = userDefaults.stringArray(forKey: "location") ?? []
            HistoryArray.append(address.text!)
            userDefaults.set(HistoryArray, forKey: "location")
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
    
    // speech variables
    let audioEngine = AVAudioEngine()
    let speechReconizer : SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var task : SFSpeechRecognitionTask!
    var isStart : Bool = false
    
    var globalJackpot = 0
    
    
    
    // defening the start button
    
    @IBAction func btn_start_stop(_ sender: Any) {
           //MARK:- Coding for start and stop sppech recognization...!
           isStart = !isStart
           if isStart {
               startSpeechRecognization()
               btn_start.setTitle("STOP", for: .normal)
              
           }else {
               cancelSpeechRecognization()
               btn_start.setTitle("START", for: .normal)
               
           }
       }
    
    // alert message
    func alertView(message : String) {
        let contrller = UIAlertController.init(title: "Error in accessing..!", message: message, preferredStyle: .alert)
        contrller.addAction(UIAlertAction(title: "OK", style: .default , handler: { (_) in
            contrller.dismiss(animated: true, completion: nil)
        }))
        self.present(contrller, animated: true, completion: nil)
    }
    
   
    
    
    // starting the speech recoginisation
    func startSpeechRecognization(){
            let node = audioEngine.inputNode
            let recordingFormat = node.outputFormat(forBus: 0)
            
            node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
                self.request.append(buffer)
            }
            
            audioEngine.prepare()
            do {
                try audioEngine.start()
            } catch let error {
                alertView(message: "Error comes here for starting the audio listner =\(error.localizedDescription)")
            }
            
            guard let myRecognization = SFSpeechRecognizer() else {
                self.alertView(message: "Recognization is not allow on your local")
                return
            }
            
            if !myRecognization.isAvailable {
               self.alertView(message: "Recognization is free right now, Please try again after some time.")
            }
            
            task = speechReconizer?.recognitionTask(with: request, resultHandler: { (response, error) in
                guard let response = response else {
                    if error != nil {
                        self.alertView(message: error.debugDescription)
                    }else {
                        self.alertView(message: "Problem in giving the response")
                    }
                    return
                }
                
                let message = response.bestTranscription.formattedString
                print("Message : \(message)")
                self.lb_speech.text = message
                
                
            })}
        
        // cancelling the speech
        func cancelSpeechRecognization() {
               task.finish()
               task.cancel()
               task = nil
               
               request.endAudio()
               audioEngine.stop()
              
               if audioEngine.inputNode.numberOfInputs > 0 {
                   audioEngine.inputNode.removeTap(onBus: 0)
               }
            
    
  
    
    }
    
    
}

