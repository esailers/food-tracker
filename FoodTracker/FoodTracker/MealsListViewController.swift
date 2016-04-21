//
//  MealsListViewController.swift
//  FoodTracker
//
//  Created by Eric Sailers on 4/19/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import UIKit

class MealsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MealViewControllerDelegate {
    
    // MARK: - Properties
    
    let cellIdentifier = "mealCellIdentifier"
    
    var meals = [Meal]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    var editBarButton: UIBarButtonItem!
    
    // MARK: - UIViewController lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedMeals = loadMeals() {
            meals += savedMeals
        } else {
            meals = Meal.loadSampleMeals()
        }
        
        editBarButton = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: #selector(self.editMeals(_:)))
        navigationItem.leftBarButtonItem = editBarButton
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }

    // MARK: - Actions
    
    func editMeals(sender: UIBarButtonItem) {
        if tableView.editing {
            editBarButton.title = "Edit"
            addBarButton.enabled = true
            tableView.setEditing(false, animated: true)
        } else {
            editBarButton.title = "Done"
            addBarButton.enabled = false
            tableView.setEditing(true, animated: true)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MealTableViewCell
        let meal = meals[indexPath.row]
        cell.nameLabel.text = meal.name
        cell.photoImageView.image = meal.photo
        cell.ratingControl.rating = meal.rating
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            removeMeal(indexPath)
            saveMeals()
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // MARK: - UITableViewDelegate

    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let button = UITableViewRowAction(style: .Default, title: "Delete") { (action, indexPath) in
            self.removeMeal(indexPath)
            self.saveMeals()
        }
        
        // Began editing tableView row
        editBarButton.title = "Done"
        addBarButton.enabled = false
        
        return [button]
    }
    
    func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
        // Ended editing tableView row
        editBarButton.title = "Edit"
        addBarButton.enabled = true
    }
    
    func removeMeal(indexPath: NSIndexPath) {
        meals.removeAtIndex(indexPath.row)
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    
    private struct StoryboardSegue {
        static let kSegueToNewMeal = "segueToAddMeal"
        static let kSegueToEditMeal = "segueToEditMeal"
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == StoryboardSegue.kSegueToEditMeal {
            if let mealDetailViewController = segue.destinationViewController as? MealViewController, indexPath = tableView.indexPathForSelectedRow {
                let selectedMeal = meals[indexPath.row]
                mealDetailViewController.meal = selectedMeal
                mealDetailViewController.delegate = self
            }
        } else if segue.identifier == StoryboardSegue.kSegueToNewMeal {
            if let destination = segue.destinationViewController as? UINavigationController, mealVC = destination.topViewController as? MealViewController {
                mealVC.delegate = self
                mealVC.isNewMeal = true
            }
        }
    }
    
    /* Unwind segue disconnected in order to utilize a delegate for passing back data
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? MealViewController, meal = sourceViewController.meal {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                meals[selectedIndexPath.row] = meal
            } else {
                meals.append(meal)
            }
            saveMeals()
        }
    }
    */
    
    // MARK: - MealViewControllerDelegate
    
    func didAddMeal(meal: Meal) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            meals[selectedIndexPath.row] = meal
        } else {
            meals.append(meal)
        }
        
        self.saveMeals()
        self.tableView.reloadData()
    }
    
    // MARK: - NSCoding
    
    func saveMeals() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(meals, toFile: Meal.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save meals")
        }
    }
    
    func loadMeals() -> [Meal]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Meal.ArchiveURL.path!) as? [Meal]
    }

}
