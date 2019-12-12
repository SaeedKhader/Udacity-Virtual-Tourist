//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Saeed Khader on 07/12/2019.
//  Copyright © 2019 Saeed Khader. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, UIGestureRecognizerDelegate {

    
    // MARK: - UI Properties
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deleteModeView: DeleteModeView!
    @IBOutlet weak var deleteButton: UIButton!
    
    
    // MARK: - Properties
    
    var dataController: DataController!
    var pins: [Pin] = []
    var annotaions: [Int:Pin] = [:]
    var isDeleteModeOn = false
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataController = appDelegate.dataController
        
        mapView.delegate = self
       
        let gestureReconizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureReconizer:)))
        gestureReconizer.delegate = self
        mapView.addGestureRecognizer(gestureReconizer)
        
        fetchData()
        
        setDeleteButtonStyle(pressed: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(viewAppeared), name: Notification.Name("mapViewAppeared"), object: nil)
        
    }
    
    @objc func viewAppeared() {
        mapView.setCenter(mapView.selectedAnnotations[0].coordinate, animated: true)
        mapView.deselectAnnotation(mapView.selectedAnnotations[0], animated: true)
    }

    
    // MARK: - Data
    
    func fetchData() {
           let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
           if let results = try? dataController.viewContext.fetch(fetchRequest) {
               pins = results
               for pin in pins {
                   let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                   addAnnotation(coordinate: coordinate, pin: pin)
               }
           }
       }
    
    
    // MARK: - Actions
    
    @IBAction func deleteTapped(_ sender: Any) {
        isDeleteModeOn.toggle()
        setDeleteButtonStyle(pressed: isDeleteModeOn)
        UIView.animate(withDuration: 0.2, animations: {
            self.deleteModeView.alpha = self.isDeleteModeOn ? 1 : 0
        })
    }
    
    func addAnnotation(coordinate: CLLocationCoordinate2D, pin: Pin) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        annotaions[annotation.hash] = pin
    }
    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == .began {
            let location = gestureReconizer.location(in: mapView)
            let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
            
            let pin = Pin(context: dataController.viewContext)
            pin.latitude = coordinate.latitude
            pin.longitude = coordinate.longitude
            try? dataController.viewContext.save()

            addAnnotation(coordinate: coordinate, pin: pin)
            gestureReconizer.state = .ended
        }
    }
    
    
    // MARK: - Style Functions
    
    func setDeleteButtonStyle(pressed: Bool) {
        if pressed {
            UIView.animate(withDuration: 0.3) {
                self.deleteButton.tintColor = .systemRed
                self.deleteButton.layer.shadowRadius = 2
                self.deleteButton.layer.shadowOffset = CGSize(width: 0, height: 2)
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.deleteButton.layer.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                self.deleteButton.layer.cornerRadius = 20
                self.deleteButton.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                self.deleteButton.tintColor = .black
                self.deleteButton.layer.shadowRadius = 5
                self.deleteButton.layer.shadowOpacity = 0.2
                self.deleteButton.layer.shadowOffset = CGSize(width: 0, height: 3)
            }
        }
    }
}


// MARK: - Map View Delegate

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let pin = annotaions[view.annotation!.hash]!
        if isDeleteModeOn {
            dataController.viewContext.delete(pin)
            try? dataController.viewContext.save()
            mapView.removeAnnotation(view.annotation!)
        } else {
            UIView.animate(withDuration: 0.3) {
                self.deleteButton.alpha = 0
            }
            zoomIn(view)
            let photosVC = storyboard?.instantiateViewController(identifier: "photosVC") as! PhotosViewController
            photosVC.pin = pin
            photosVC.mapVCdeleteBtn = deleteButton
            photosVC.modalPresentationStyle = .overFullScreen
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.present(photosVC, animated: true, completion: nil)
            }
        }
    }
    
    fileprivate func zoomIn(_ view: MKAnnotationView) {
        let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        var coordinate = view.annotation!.coordinate
        coordinate.latitude -= Double(UIScreen.main.bounds.height/1800)
        self.mapView.setRegion(MKCoordinateRegion(center: coordinate, span: span), animated: true)
    }
    
}

