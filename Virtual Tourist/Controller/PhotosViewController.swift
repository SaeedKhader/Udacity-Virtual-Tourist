//
//  PhotosViewController.swift
//  Virtual Tourist
//
//  Created by Saeed Khader on 07/12/2019.
//  Copyright © 2019 Saeed Khader. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher

class PhotosViewController: UIViewController {
    
    
    // MARK: - UI Properties
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var noPhotoLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var mapVCdeleteBtn: UIButton!
    
    
    // MARK: - Properties
    
    var pin: Pin!
    var dataController: DataController!
    var fRC: NSFetchedResultsController<Photo>!
    var blockOperations = [BlockOperation]()
    
    deinit {
       for operation in blockOperations {
           operation.cancel()
       }
       
       blockOperations.removeAll(keepingCapacity: false)
    }
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataController = appDelegate.dataController
                
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        
        let tapGusture = UITapGestureRecognizer(target: self, action: #selector(dismissView(_:)))
        backgroundView.addGestureRecognizer(tapGusture)
        
        setUpFlowLayout()
        setUpButtonStyle(button: newCollectionBtn)
        setUpButtonStyle(button: deleteBtn)
        
        setUpFetchedResultsController()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fRC = nil
    }
    
    
    // MARK: - Actions
    
    @IBAction func dismissView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        UIView.animate(withDuration: 0.3) {
            self.mapVCdeleteBtn.alpha = 1
        }
        NotificationCenter.default.post(name: Notification.Name("mapViewAppeared"), object: nil)
    }
    
    @IBAction func newCollectionTapped(_ sender: Any) {
        
        if let photos = fRC.fetchedObjects {
            for photo in photos {
                fRC.managedObjectContext.delete(photo)
            }
            try? fRC.managedObjectContext.save()
            
            collectionView.reloadData()
        }
        
        FlickrClient.photoSearch(lat: pin.latitude, lon: pin.longitude, page: pin.photosPage + 1, completion: handlePhotoSearchResponse(urls:error:))

    }
    
    @IBAction func deleteTapped(_ sender: Any) {
        if let indexes = collectionView.indexPathsForSelectedItems {
            for index in indexes {
                let photoToDelete = fRC.object(at: index)
                fRC.managedObjectContext.delete(photoToDelete)
                let cell = collectionView.cellForItem(at: index) as! PhotoCell
                cell.setUpStyle(selected: false)
            }
            try? fRC.managedObjectContext.save()
        }
        deleteModeOn(false)
    }
    
    
    // MARK: - Style Functions
  
    fileprivate func setUpFlowLayout() {
        let width = ( UIScreen.main.bounds.width - 30 ) / 3
        flowLayout.minimumLineSpacing = 5
        flowLayout.minimumInteritemSpacing = 5
        flowLayout.estimatedItemSize = CGSize(width: width, height: width)
    }
    
    fileprivate func setUpButtonStyle(button: UIButton) {
        button.layer.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        button.layer.cornerRadius = 15
        button.layer.shadowColor = #colorLiteral(red: 0.1215686275, green: 0.1294117647, blue: 0.1411764706, alpha: 0.5)
        button.layer.shadowOffset = .zero
        button.layer.shadowOpacity = 0.8
        button.layer.shadowRadius = 8
    }
    
    func deleteModeOn(_ bool: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.newCollectionBtn.alpha = bool ? 0 : 1
            self.deleteBtn.alpha = bool ? 1 : 0
        }
    }
    
}


// MARK: - Collection View

extension PhotosViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fRC.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let photo = self.fRC.object(at: indexPath)
        cell.getPhoto(photo: photo)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
        cell.setUpStyle(selected: true)
        deleteModeOn(true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
        cell.setUpStyle(selected: false)
        if collectionView.indexPathsForSelectedItems?.isEmpty ?? true {
            deleteModeOn(false)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! PhotoCell).imageView.kf.cancelDownloadTask()
    }
    
}


// MARK: - Fetched Result Controller

extension PhotosViewController: NSFetchedResultsControllerDelegate {
    
    fileprivate func setUpFetchedResultsController() {
                
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        
        fRC = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fRC.delegate = self
        
        do {
           try fRC.performFetch()
        } catch {
           fatalError("The fetch couldn't be preformed: \(error.localizedDescription)")
        }
        
        if fRC.fetchedObjects?.isEmpty ?? true {
            FlickrClient.photoSearch(lat: pin.latitude, lon: pin.longitude, page: pin.photosPage, completion: handlePhotoSearchResponse(urls:error:))
        } else {
            activityIndicator.stopAnimating()
        }
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            blockOperations.append(BlockOperation(block: {
                 self.collectionView.insertItems(at: [newIndexPath!])
            }))
        case .delete:
            blockOperations.append(BlockOperation(block: {
                 self.collectionView.deleteItems(at: [indexPath!])
            }))
        default:
            return
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({
            for operation in blockOperations {
                operation.start()
            }
            blockOperations.removeAll(keepingCapacity: false)
        }, completion: nil)
    }

    
    func handlePhotoSearchResponse(urls: [String], error: Error?) {
        guard error == nil else {
            showAlert(title: "Getting Photos Failed", message: error!.localizedDescription)
            return
        }
        if urls.isEmpty {
            UIView.animate(withDuration: 0.3) {
                self.noPhotoLabel.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.noPhotoLabel.alpha = 0
            }
            pin.photosPage = pin.photosPage + 1
            for url in urls {
                let photo = Photo(context: fRC.managedObjectContext)
                photo.pin = self.pin
                photo.url = url
            }
            try? dataController.viewContext.save()
        }
        activityIndicator.stopAnimating()
    }
    
    func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: dismissView(_:)))
        show(alertVC, sender: self)
    }
    
}
