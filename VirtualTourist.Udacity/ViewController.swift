//
//  ViewController.swift
//  VirtualTourist.Udacity
//
//  Created by Alexis Omar Marquez Castillo on 18/10/20.
//  Copyright © 2020 udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreData
class TravelViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var dataController: DataController!
    var pins: [NSObject] = []
    var photosArray = [String]()
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
    
    fileprivate func Pinfetch() {
        //Fetching Pins from CoreData persistent store
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Pin")
        do {
            self.pins = try dataController.viewContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    override func viewDidLoad() {
           super.viewDidLoad()
        dataController = (UIApplication.shared.delegate as! AppDelegate).dataController
       Pinfetch()
               let uiLPGR = UILongPressGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        
         self.mapView.addGestureRecognizer(uiLPGR)
           view.addSubview(imageView)
           let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
           gestureRecognizer.delegate = self
           mapView.addGestureRecognizer(gestureRecognizer)
           APIManager.shared.getPhotos { (result) in
               switch result {
               case .Success(let Fotos):
                for element in Fotos.photos.photo {
                       
                       let url =  "https://farm\(element.farm).static.flickr.com/\(element.server)/\(element.id)_\(element.secret).jpg"
                       
                       self.photosArray.append(url)
                       print(self.photosArray)
                   }
               case .Error(let error):
                   print(error)
               }
        }
    }
override func viewWillAppear(_ animated: Bool) {
super.viewWillAppear(animated)
                self.refresh()
            }
                
            //MARK: - IBActions
                
            private func refresh() {
                self.mapView.removeAnnotations(mapView.annotations)
              
    }

       
       @objc func handleTap(gestureRecognizer: UILongPressGestureRecognizer) {
           
           let location = gestureRecognizer.location(in: mapView)
           let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
           
           // Add annotation:
           let annotation = MKPointAnnotation()
           annotation.coordinate = coordinate
           annotation.title = "Ubicación"
           annotation.subtitle =  "latitude: \(coordinate.latitude)" + " " +  "longitude: \(coordinate.longitude)"
           mapView.addAnnotation(annotation)
         let newPin = Pin(context: dataController.viewContext)
               newPin.latitude = annotation.coordinate.latitude
               newPin.longitude = annotation.coordinate.longitude
               try? dataController.viewContext.save()
               
               //self.Pinfetch()
               //self.refresh()
               }
       
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "Album" {
            _ = segue.destination
               // TODO: something
           }
        
       }
   }

   extension TravelViewController: MKMapViewDelegate {

       func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
           performSegue(withIdentifier: "Album", sender: nil)
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

