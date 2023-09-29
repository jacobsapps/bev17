//
//  BeerTests.swift
//  DomainTests
//
//  Created by Jacob Bartlett on 02/04/2023.
//

import XCTest
@testable import Domain

final class BeerTests: XCTestCase {
    
    let decoder = JSONDecoder()
    
    func test_decodeJSON_parsesKeyInformation() {
        
        guard let jsonData = getBeerJSON().data(using: .utf8),
              let beer = try? decoder.decode([Beer].self, from: jsonData).first else {
            XCTFail("Failed to decode test data")
            return
        }
        
        XCTAssertEqual(beer.id, 1)
        XCTAssertEqual(beer.name, "Buzz")
        XCTAssertEqual(beer.tagline, "A Real Bitter Experience.")
        XCTAssertEqual(beer.abv, 4.5)
    }
    
    func test_decodeJSON_parsesSupplementaryInformation() {
        
        guard let jsonData = getBeerJSON().data(using: .utf8),
              let beer = try? decoder.decode([Beer].self, from: jsonData).first else {
            XCTFail("Failed to decode test data")
            return
        }
        
        XCTAssertFalse(beer.ingredients.malt.isEmpty)
        XCTAssertFalse(beer.ingredients.hops.isEmpty)
        XCTAssertNotNil(beer.ingredients.yeast)
    }
    
    func test_decodeJSON_parsesSnakeCaseCodingKeys() {
        
        guard let jsonData = getBeerJSON().data(using: .utf8),
              let beer = try? decoder.decode([Beer].self, from: jsonData).first else {
            XCTFail("Failed to decode test data")
            return
        }
        
        XCTAssertEqual(beer.firstBrewed, "09/2007")
        XCTAssertEqual(beer.imageURL, "https://images.punkapi.com/v2/keg.png")
        XCTAssertEqual(beer.foodPairing, [
            "Spicy chicken tikka masala",
            "Grilled chicken quesadilla",
            "Caramel toffee cake"
        ])
    }
    
    func test_decodeJSON_withInvalidDataFormat_throwsError() {
        
        do {
            let invalidData = "[{\"fake-data\"}]".data(using: .utf8)
            _ = try decoder.decode([Beer].self, from: invalidData!)
            XCTFail("Expected to fail")
            
        } catch {
            XCTAssertEqual(error.localizedDescription,
                           "The data couldn’t be read because it isn’t in the correct format.")
        }
    }
    
    func test_equality_checksForMatchingID() {
        let beerA = createBeer(id: 0, name: "Beer A")
        let beerB = createBeer(id: 1, name: "Beer B")
        let beerC = createBeer(id: 1, name: "Beer C")
        
        XCTAssertTrue(beerA != beerB)
        XCTAssertTrue(beerA != beerC)
        XCTAssertTrue(beerB == beerC)
    }
    
    func test_optionalValues() {
        let beer = createBeer(id: 0, name: "Beer A", imageURL: nil, yeast: nil)

        XCTAssertNil(beer.imageURL)
        XCTAssertNil(beer.ingredients.yeast)
    }

    func test_sample_createsSampleBeer() {
        let beer = Beer.sample()
        
        XCTAssertEqual(beer.id, 1)
        XCTAssertEqual(beer.name, "Beer")
        XCTAssertEqual(beer.tagline, "A nice beer")
        XCTAssertEqual(beer.abv, 5.5)
    }
    
    private func createBeer(id: Int, name: String, imageURL: String? = "", yeast: String? = "") -> Beer {
        Beer(id: id,
             name: name,
             tagline: "",
             firstBrewed: "",
             details: "",
             imageURL: imageURL,
             abv: 0,
             ingredients: Ingredients(malt: [], hops: [], yeast: yeast),
             foodPairing: [])
    }
    
    private func getBeerJSON() -> String {
"""
[
    {
        "id": 1,
        "name": "Buzz",
        "tagline": "A Real Bitter Experience.",
        "first_brewed": "09/2007",
        "description": "A light, crisp and bitter IPA brewed with English and American hops. A small batch brewed only once.",
        "image_url": "https://images.punkapi.com/v2/keg.png",
        "abv": 4.5,
        "ibu": 60,
        "target_fg": 1010,
        "target_og": 1044,
        "ebc": 20,
        "srm": 10,
        "ph": 4.4,
        "attenuation_level": 75,
        "volume": {
            "value": 20,
            "unit": "litres"
        },
        "boil_volume": {
            "value": 25,
            "unit": "litres"
        },
        "method": {
            "mash_temp": [
                {
                    "temp": {
                        "value": 64,
                        "unit": "celsius"
                    },
                    "duration": 75
                }
            ],
            "fermentation": {
                "temp": {
                    "value": 19,
                    "unit": "celsius"
                }
            },
            "twist": null
        },
        "ingredients": {
            "malt": [
                {
                    "name": "Maris Otter Extra Pale",
                    "amount": {
                        "value": 3.3,
                        "unit": "kilograms"
                    }
                },
                {
                    "name": "Caramalt",
                    "amount": {
                        "value": 0.2,
                        "unit": "kilograms"
                    }
                },
                {
                    "name": "Munich",
                    "amount": {
                        "value": 0.4,
                        "unit": "kilograms"
                    }
                }
            ],
            "hops": [
                {
                    "name": "Fuggles",
                    "amount": {
                        "value": 25,
                        "unit": "grams"
                    },
                    "add": "start",
                    "attribute": "bitter"
                },
                {
                    "name": "First Gold",
                    "amount": {
                        "value": 25,
                        "unit": "grams"
                    },
                    "add": "start",
                    "attribute": "bitter"
                },
                {
                    "name": "Fuggles",
                    "amount": {
                        "value": 37.5,
                        "unit": "grams"
                    },
                    "add": "middle",
                    "attribute": "flavour"
                },
                {
                    "name": "First Gold",
                    "amount": {
                        "value": 37.5,
                        "unit": "grams"
                    },
                    "add": "middle",
                    "attribute": "flavour"
                },
                {
                    "name": "Cascade",
                    "amount": {
                        "value": 37.5,
                        "unit": "grams"
                    },
                    "add": "end",
                    "attribute": "flavour"
                }
            ],
            "yeast": "Wyeast 1056 - American Ale™"
        },
        "food_pairing": [
            "Spicy chicken tikka masala",
            "Grilled chicken quesadilla",
            "Caramel toffee cake"
        ],
        "brewers_tips": "The earthy and floral aromas from the hops can be overpowering. Drop a little Cascade in at the end of the boil to lift the profile with a bit of citrus.",
        "contributed_by": "Sam Mason <samjbmason>"
    }
]
"""
    }
}
