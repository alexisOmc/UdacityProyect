//
//  ViewController.swift
//  VirtualTourist.Udacity//
//  Created by Alexis Omar Marquez Castillo on 18/10/20.
//  Copyright © 2020 udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class TravelViewController: UIViewController, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var labelDelete: UILabel!
    @IBOutlet weak var EditButtom: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var dataController: DataController!
    var pins: [NSManagedObject] = []
    var pin: Pin!
    var deletedPin : Bool?
    var fetchResultController:NSFetchedResultsController<Pin>!
    fileprivate let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        return manager
    }()
    private let imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        imageView.image = UIImage(named: "logo-u")
        return imageView
    }()
    
    fileprivate func setupFetchedResultsController(latitude:Double,longitude:Double) {
        print("Pin: setup fetch result controller!")
        fetchResultController = nil
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        // TODO: Need to  update the predicate
        print("predicate is \(latitude) and \(longitude)")
        let latNSNumber:NSNumber = NSNumber.init(value: latitude)
        let longNSNumber:NSNumber = NSNumber.init(value: longitude)
        // fixed by Mentor's suggestion: Latitude and longitude are both Double values, you can't use %@ with this type, need to use NSNumbers instead
        let predicateLatitude = NSPredicate(format: "latitude == %@", latNSNumber)
        let predicateLongtitude = NSPredicate(format: "longitude == %@", longNSNumber)
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicateLatitude, predicateLongtitude])
        fetchRequest.predicate = andPredicate
        let sortDescriptor = NSSortDescriptor(key: "newDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        
        fetchResultController.delegate = self
        do {
            try fetchResultController.performFetch()
            // if no data object is fetched, then persists the Pin
            if let count = fetchResultController.fetchedObjects?.count, count == 0 {
                // let's create an new pin
                print("Add new pin")
                Pinfetch(latitude: latitude, longitude: longitude)
            } else {
                print("we found existing pin")
                let existingPins:[Pin] = fetchResultController.fetchedObjects!
                pin = existingPins[0]
                print("we found existing pin with created date: \(String(describing: pin.newDate))")
            }
        } catch {
            fatalError("Error when try to fetch the album \(error.localizedDescription)")
        }
    }
    
    
    
    fileprivate func Pinfetch(latitude:Double, longitude:Double){
        
        pin = Pin(context: dataController.viewContext)
        // HOW To ADD the photo ?
        pin.newDate = Date()
        pin.latitude = latitude
        pin.longitude = longitude
        try? dataController.viewContext.save()
        print("Saved pin to core data")
    }
    
    
    @IBAction func EditButtom(_ sender: UIBarButtonItem) {
        if labelDelete.isHidden == !isEditing {
            labelDelete.isHidden = false
            deletedPin = true
            
        }else{
            if labelDelete.isHidden == isEditing{
                labelDelete.isHidden = true
                deletedPin = false
                
                
                
            }
        }
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setUpMap()
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        dataController = (UIApplication.shared.delegate as! AppDelegate).dataController
        
        let uiLPGR = UILongPressGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        self.mapView.addGestureRecognizer(uiLPGR)
        //Pinfetch(lat: pin.latitude, lon: pin.longitude)
        
        
        view.addSubview(imageView)
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
        loadPins()
        
        /*APIManager.shared.getPhotos(lat: pin.latitude, lon: pin.longitude) { (result) in
         
         switch result {
         case .Success(let Fotos):
         for element in Fotos.photos.photo {
         let url = "https://farm\(element.farm).static.flickr.com/\(element.server)/\(element.id)_\(element.secret).jpg"
         
         self.photosArray.append(url)
         //print(self.photosArray)
         }
         case .Error(let error):
         print(error)
         }
         }*/
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.refresh()
        
    
        
    }
    
    //MARK: - IBActions
    
    private func refresh() {
        self.mapView.removeAnnotations(mapView.annotations)
        self.setNeedsUpdateOfHomeIndicatorAutoHidden()
        self.setUpPins()
    }
    private func setUpMap() {
        //Set MapView's delegate and properties
        
        self.mapView.delegate = self
        self.mapView.isZoomEnabled = true
        self.mapView.isScrollEnabled = true
        
    }
    private func setUpPins() {
        
        var annotations = [MKPointAnnotation]()
        
        //MARK: using CoreData to populate map with pins
        for dictionary in pins {
            
            let lat = CLLocationDegrees((dictionary.value(forKeyPath: "latitude") as? CLLocationDegrees) ?? 0.0 )
            let long = CLLocationDegrees((dictionary.value(forKeyPath: "longitude") as? Double) ?? 0.0 )
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            // Creating the annotation and setting its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            // Adding the annotation in an array of annotations.
            annotations.append(annotation)
            
        }
    }
    
    
    
    @objc func handleTap(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began{
            print("prueba")
            
        }
        if deletedPin == true {
            print("No hagas nada")
        } else {
            let location = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            
            // Add annotation:
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "Ubicación: \(coordinate.latitude)" + " " + "longitude: \(coordinate.longitude) "
            annotation.subtitle =  "latitude: \(coordinate.latitude)" + " " +  "longitude: \(coordinate.longitude)"
            mapView.addAnnotation(annotation)
            
            
            
            let newPin = Pin(context: dataController.viewContext)
            newPin.latitude = annotation.coordinate.latitude
            newPin.longitude = annotation.coordinate.longitude            
            
            try? dataController.viewContext.save()
            pins.append(newPin)
            
            print("Save pin to core data only when it does not save before!")
            setupFetchedResultsController(latitude: coordinate.latitude, longitude: coordinate.longitude)
            //self.Pinfetch(lat: pin.latitude, lon: pin.longitude)
        }
        
    }
  

    func loadPins (){
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        do {
            pins = try dataController.viewContext.fetch(fetchRequest)
            for pin in pins{
                drawPin(pin: pin as! Pin)
            }
        } catch {
            let nerror = error as NSError
            fatalError("DataController error \(nerror.localizedDescription)")
            
        }
        
    }
    
    
    
    @objc func tapPin(gestureRecognizer: UILongPressGestureRecognizer) {
        print("funciontapPin")
    }
    func drawPin(pin:Pin){
        let location = MKPointAnnotation()
        location.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        
        
        
          
        
        mapView.addAnnotation(location)
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PhotoAlbumViewController {
            guard let passedPin = sender as? Pin else {
                return
            }
            vc.pin = passedPin
            vc.dataController = dataController
            /*if segue.identifier == "Album" {
             _ = segue.destination*/
            // TODO: something
        }
        
    }
}

extension TravelViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let annotation = view.annotation else {
            return
        }
        if  deletedPin == true{
            
            let thisCoordinate = annotation.coordinate
            mapView.deselectAnnotation(annotation, animated: true)
            for pin in pins as! [Pin] {
                if pin.latitude == thisCoordinate.latitude && pin.longitude == thisCoordinate.longitude {
                    //setUpFetchController(lat: pin.latitude, lon: pin.longitude)                    //performSegue(withIdentifier: "Album", sender: pin) //Sending the Pin through segue!
                    setupFetchedResultsController(latitude: thisCoordinate.latitude, longitude: thisCoordinate.longitude)
                    for annotation in self.mapView.annotations {
                        if (annotation.isEqual(view.annotation)) {
                            self.mapView.removeAnnotation(annotation)
                            pinDelet(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)          // let pin = view.annotation
                            
                            //self.mapView.removeAnnotation(pin!)
                            
                        }
                    }
                }else{
                    setupFetchedResultsController(latitude: thisCoordinate.latitude, longitude: thisCoordinate.longitude)
                }
            }
        } else {
            
            //setUpFetchController(lat: pin.latitude, lon: pin.longitude)
            let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
            VC1.latitude = annotation.coordinate.latitude
            
            VC1.longitude = annotation.coordinate.longitude
            
            //self.navigationController!.pushViewController(VC1, animated: true)
            
            
            
            mapView.deselectAnnotation(view.annotation, animated: true)
            navigationController?.pushViewController(VC1, animated: true)
        }
        
    }
    func pinDelet(latitude: Double, longitude: Double) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        request.returnsObjectsAsFaults = false
        // If you want to delete data on basis of some condition then you can use NSPredicate
        let predicate = NSPredicate(format: "latitude == \(latitude) AND longitude == \(longitude)" )
        request.predicate = predicate
        
        do {
            let listofPins = try context.fetch(request)
            for pin in listofPins as! [NSManagedObject] { // Fetching Object
                context.delete(pin) // Deleting Object
            }
        } catch {
            print("no se puedo")
        }
        
        // Saving the Delete operation
        do {
            try context.save()
        } catch {
            print("no se guardo")
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.center = view.center
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
            self.animate()
        })
    }
    private func animate (){
        UIView.animate(withDuration: 1, animations: {
            let size = self.view.frame.width * 3
            let diffx = size - self.view.frame.size.width
            let diffy = self.view.frame.size.height - size
            self.imageView.frame = CGRect(x: -(diffx/2), y: diffy/2, width: size, height: size)
            
        })
        UIView.animate(withDuration: 1.5, animations: {
            self.imageView.alpha = 0
            
        })
        
    }
    
}


