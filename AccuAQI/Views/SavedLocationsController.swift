//
//  SavedLocationsController.swift
//  AccuAQI
//
//  Created by Jin Kim on 11/12/20.
//

import UIKit
import CoreData

class SavedLocationsController: UITableViewController {
    
    // User locations
    var locations: [NSManagedObject] = []
    var lat: Double = 0.0
    var long: Double = 0.0
    var index: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        addButton()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadData()
        addButton()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.destination is SpecialistTrackingController {
//            let vc = segue.destination as? SpecialistTrackingController
//            vc?.name = name!
//        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        long = (locations[indexPath.row].value(forKey: "long") as! Double)
        lat = (locations[indexPath.row].value(forKey: "lat") as! Double)
        index = indexPath.row
        performSegue(withIdentifier: "ToCity", sender: self)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        
        cell.clipsToBounds = true
        
        // Getting the contents of the selected row
        // See UserCell.swift in Custom group
        cell.configure(locations[indexPath.row].value(forKey: "name") as! String)
        
        return cell
    }
    
    // Right swipe 'Delete'
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let context = appDelegate.persistentContainer.viewContext
            let commit = locations[indexPath.row]

            locations.remove(at: indexPath.row)
            context.delete(commit)
            
            do {
                try context.save()
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print("Error Deleting")
            }
            tableView.reloadData()
        }
    }
    
    func loadData() {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequestLocations = NSFetchRequest<NSManagedObject>(entityName: "Location")
        
        do {
            locations = try managedContext.fetch(fetchRequestLocations)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    // Add new session
    @objc func addButtonTap() {
        showInputDialog(title: "Add a location",
                        subtitle: "Please enter with 'City, State'",
                        actionTitle: "Add",
                        cancelTitle: "Cancel",
                        inputPlaceholder: "Ex: John Appleseed",
                        inputKeyboardType: .emailAddress, actionHandler:
                            { (input: String?) in
                                self.saveLocation(input!)
                            })
        tableView.reloadData()
    }
    
    func addButton() {
        let addButton = UIBarButtonItem()
        addButton.title = "Add Location"
        addButton.action = #selector(addButtonTap)
        addButton.target = self
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    func saveLocation(_ name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Location", in: managedContext)!
        
        let loc = NSManagedObject(entity: entity, insertInto: managedContext)
        
        loc.setValue(name, forKeyPath: "name")
        loc.setValue(name, forKeyPath: "name")
        loc.setValue(name, forKeyPath: "name")
        loc.setValue(name, forKeyPath: "name")
        
        do {
            try managedContext.save()
            locations.append(loc)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        tableView.reloadData()
    }
}

// Used for getting input
extension UIViewController {
    func showInputDialog(title: String? = nil,
                         subtitle: String? = nil,
                         actionTitle: String? = "Add",
                         cancelTitle: String? = "Cancel",
                         inputPlaceholder: String? = nil,
                         inputKeyboardType: UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {

        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        }
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            actionHandler?(textField.text)
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))

        self.present(alert, animated: true, completion: nil)
    }
}
