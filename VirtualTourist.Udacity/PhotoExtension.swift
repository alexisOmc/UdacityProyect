//
//  PhotoExtension.swift
//  VirtualTourist.Udacity
//
//  Created by Alexis Omar Marquez Castillo on 23/11/20.
//  Copyright © 2020 udacity. All rights reserved.
//

import Foundation
import UIKit


extension PhotoAlbumViewController {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return photosArray.count
      }
      
      func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellID, for: indexPath) as! CellCollectionViewCollectionViewCell
          
          DispatchQueue.global(qos: .background).async {
              do {
                  let data = try Data.init(contentsOf: URL.init(string: self.photosArray[indexPath.row])!)
                  let image : UIImage = UIImage(data: data)!
                  DispatchQueue.main.async {
                      
                  
                  cell.photo.image = image
                  }
              } catch {
                  
              }
       
              
         
      }
       return cell
      }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let objectToDelete = fetchedController.object(at: indexPath)
        dataController.viewContext.delete(objectToDelete)
        try? dataController.viewContext.save()
    }

}


// MARK: - Collection View Flow Layout Delegate




