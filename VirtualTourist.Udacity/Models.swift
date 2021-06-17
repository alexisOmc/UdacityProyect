//
//  Models.swift
//  Mapa
//
//  Created by Alexis Omar Marquez Castillo on 17/10/20.
//  Copyright © 2020 udacity. All rights reserved.
//


import Foundation
 
struct Fotos: Codable {
 let photos: PhotosClass
 let stat: String
 
}
struct PhotosClass: Codable {
let page, pages, perpage, total: Int
let photo: [Photo]

}
struct Photo: Codable {

    let id, owner, secret, server: String

    let farm: Int

    let title: String

    let ispublic, isfriend, isfamily: Int

}

