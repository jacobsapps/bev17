//
//  BeerModel.swift
//
//
//  Created by Jacob Bartlett on 23/09/2023.
//

import Domain
import SwiftData

@Model
final class BeerModel {
    
    @Attribute(.unique) var id: Int
    let name: String
    let tagline: String
    let firstBrewed: String
    let details: String
    let imageURL: String?
    let abv: Double
    let ingredients: Ingredients
    let foodPairing: [String]
    
    var beer: Beer {
        Beer(id: id,
             name: name,
             tagline: tagline,
             firstBrewed: firstBrewed,
             details: details,
             imageURL: imageURL,
             abv: abv,
             ingredients: ingredients,
             foodPairing: foodPairing)
    }
    
    init(beer: Beer) {
        self.id = beer.id
        self.name = beer.name
        self.tagline = beer.tagline
        self.firstBrewed = beer.firstBrewed
        self.details = beer.details
        self.imageURL = beer.imageURL
        self.abv = beer.abv
        self.ingredients = beer.ingredients
        self.foodPairing = beer.foodPairing
    }
}
