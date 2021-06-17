//
//  Extension.swift
//  VirtualTourist.Udacity
//
//  Created by Alexis Omar Marquez Castillo on 11/11/20.
//  Copyright © 2020 udacity. All rights reserved.
//

import Foundation
import CoreData

/*extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        PhotoCollectionViewController.beginInteractiveMovementForItem(at: indexPath!)
        
        
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else {break}
            blockOperation.addExecutionBlock {
                self.PhotoCollectionViewController.insertItems(at: [newIndexPath])
            }
        case .delete:
            guard let indexPath = indexPath else {break}
            blockOperation.addExecutionBlock {
                self.PhotoCollectionViewController.deleteItems(at: [indexPath])
            }
        case .update:
            guard let indexPath = indexPath else {break}
            blockOperation.addExecutionBlock {
                DispatchQueue.main.async {
                    self.PhotoCollectionViewController.reloadItems(at: [indexPath])
                }
            }
        case .move:
            guard let newIndexPath = newIndexPath else {break}
            blockOperation.addExecutionBlock {
                DispatchQueue.main.async {
                    self.PhotoCollectionViewController.moveItem(at: indexPath!, to: newIndexPath)
                }
            }
            
        @unknown default:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert/delete/move/update should be possible.")
        }
        
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperation = BlockOperation()
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        PhotoCollectionViewController?.performBatchUpdates({self.blockOperation.start()}, completion: nil)
    }
}*/
