//
//  Beer.swift
//  Domain
//
//  Created by Jacob Bartlett on 01/04/2023.
//

import Foundation

public struct Beer: Codable, Equatable, Identifiable, Hashable {
    
    public let id: Int
    public let name: String
    public let tagline: String
    public let firstBrewed: String
    public let details: String
    public let imageURL: String?
    public let abv: Double
    public let ingredients: Ingredients
    public let foodPairing: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case tagline
        case firstBrewed = "first_brewed"
        case details = "description"
        case imageURL = "image_url"
        case abv
        case ingredients
        case foodPairing = "food_pairing"
    }
    
    public init(
        id: Int,
        name: String,
        tagline: String,
        firstBrewed: String,
        details: String,
        imageURL: String?,
        abv: Double,
        ingredients: Ingredients,
        foodPairing: [String]
    ) {
        self.id = id
        self.name = name
        self.tagline = tagline
        self.firstBrewed = firstBrewed
        self.details = details
        self.imageURL = imageURL
        self.abv = abv
        self.ingredients = ingredients
        self.foodPairing = foodPairing
    }
    
    public static func == (lhs: Beer, rhs: Beer) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func sample(id: Int = 1, name: String = "Beer") -> Beer {
        Beer(id: id,
             name: "Beer",
             tagline: "A nice beer",
             firstBrewed: "09/2007",
             details: "A very nice beer indeed",
             imageURL: "https://beer.com/image/1",
             abv: 5.5,
             ingredients: Ingredients(malt: [], hops: [], yeast: ""),
             foodPairing: [])
    }
}

public struct Ingredients: Codable {
    
    public let malt: [Malt]
    public let hops: [Hop]
    public let yeast: String?
    
    public init(
        malt: [Malt],
        hops: [Hop],
        yeast: String? = nil
    ) {
        self.malt = malt
        self.hops = hops
        self.yeast = yeast
    }
}

public struct Hop: Codable {
    
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
}

public struct Malt: Codable {
    
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
}
