//
//  Meal.swift
//  FoodTracker
//
//  Created by Eric Sailers on 4/19/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import UIKit

class Meal: NSObject, NSCoding {
    
    // MARK: - Properties
    
    var name: String
    var photo: UIImage?
    var rating: Int
    
    // MARK: - Archiving Data
    
    /*
     You mark the below constants with the static keyword, which means they apply to the class instead of an instance of the class. Outside of the Meal class, you’ll access the path using the syntax Meal.ArchiveURL.path!.
    */
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("meals")
    
    // MARK: - Types
    
    struct PropertyKey {
        
        /*
         You mark the below constants with the static keyword, which means they apply to the struct instead of an instance of the struct. Outside of the PropertyKey struct, you’ll access the keywords using PropertyKey following by the constant (e.g., PropertyKey.nameKey).
         */
        
        static let nameKey = "name"
        static let photoKey = "photo"
        static let ratingKey = "rating"
    }
    
    // MARK: - Initialization
    
    init?(name: String, photo: UIImage?, rating: Int) {
        self.name = name
        self.photo = photo
        self.rating = rating
        
        // Because the other initializer you defined on the Meal class, init?(name:photo:rating:), is a designated initializer, its implementation needs to call to its superclass’s initializer.
        super.init()
        
        if name.isEmpty || rating < 0 {
            return nil
        }
    }
    
    // MARK: - Load sample meals
    
    class func loadSampleMeals() -> [Meal] {
        let image1 = UIImage(named: "mealImage1")
        let image2 = UIImage(named: "mealImage2")
        let image3 = UIImage(named: "mealImage3")
        
        let meals = [
            Meal(name: "Caprese Salad", photo: image1, rating: 4)!,
            Meal(name: "Chicken and Potatoes", photo: image2, rating: 5)!,
            Meal(name: "Spaghetti and Meatballs", photo: image3, rating: 3)!
        ]
        
        return meals
    }
    
    // MARK: - NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(photo, forKey: PropertyKey.photoKey)
        aCoder.encodeInteger(rating, forKey: PropertyKey.ratingKey)
    }
    
    // Convenience initializer is secondary to primary initializer above. 'Convenience' keyword used so you don't need to call initializer from other classes.
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        
        // Because photo is an optional property of Meal, use conditional cast.
        let photo = aDecoder.decodeObjectForKey(PropertyKey.photoKey) as? UIImage
        
        let rating = aDecoder.decodeIntegerForKey(PropertyKey.ratingKey)
        
        // Must call designated initializer
        self.init(name: name, photo: photo, rating: rating)
    }
}