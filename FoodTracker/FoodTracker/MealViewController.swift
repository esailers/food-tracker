//
//  MealViewControllerViewController.swift
//  FoodTracker
//
//  Created by Eric Sailers on 4/19/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import UIKit

protocol MealViewControllerDelegate {
    func didAddMeal(meal: Meal)
}

class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Properties
    
    var delegate: MealViewControllerDelegate?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    
    var meal: Meal?
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var isNewMeal: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        nameTextField.delegate = self
        
        isNewMeal = presentingViewController is UINavigationController
        if isNewMeal {
            saveButton.enabled = false
            nameTextField.becomeFirstResponder()
        } else {
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = nil
        }
        
        if let meal = meal {
            navigationItem.title = meal.name
            nameTextField.text = meal.name
            photoImageView.image = meal.photo
            ratingControl.rating = meal.rating
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isNewMeal == false {
            save()
        }
        
        nameTextField.resignFirstResponder()
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let text = nameTextField.text ?? ""
        navigationItem.title = text
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if let textFieldText = textField.text {
            let textString = NSString.init(string: textFieldText)
            let updatedText = textString.stringByReplacingCharactersInRange(range, withString: string)
            
            if isNewMeal {
                saveButton.enabled = updatedText.isEmpty ? false : true
            }
            navigationItem.title = updatedText
        }
        
        return true
    }

    // MARK: UIImagePickerControllerDelegate

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Actions
    
    @IBAction func selectImageFromPhotoLibrary(sender: UITapGestureRecognizer) {
        // Hide the keyboard.
        nameTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .PhotoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func cancelMeal(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveMeal(sender: UIBarButtonItem) {
        save()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func save() {
        let name = nameTextField.text ?? ""
        let photo = photoImageView.image
        let rating = ratingControl.rating
        
        meal = Meal(name: name, photo: photo, rating: rating)
        
        if let meal = meal {
            delegate?.didAddMeal(meal)
        }
    }
    
    // MARK: - Navigation
    
    /* Disconnected unwind segue to use delegate
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            let name = nameTextField.text ?? ""
            let photo = photoImageView.image
            let rating = ratingControl.rating
            meal = Meal(name: name, photo: photo, rating: rating)
        }
        
    }
    */

}

