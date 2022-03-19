//
//  EventAddEditVC.swift
//  EventCount
//
//  Created by Alphonsa Varghese on 14/03/22.
//

import UIKit
import CoreData
import UserNotifications

class EventAddEditVC: UIViewController {
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var eventTextview: UITextView!
    @IBOutlet weak var datePickerOut: UIDatePicker!
    @IBOutlet weak var viewDatePickerBG: UIView!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var eventView: UIView!
    
    
    // MARK: - VARIABLES
    var passedEvent:Events?
    var isEdit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        initialSetUp()
        
    }
    
    // MARK: - ACTIONS
    
    
    @IBAction func selectDateButtonOnclick(_ sender: UIButton) {
        viewDatePickerBG.isHidden = false
    }
    
    @IBAction func cancelButtonOnClick(_ sender: UIButton) {
        viewDatePickerBG.isHidden = true
    }
    
    @IBAction func okButtonOnClick(_ sender: UIButton) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "dd/MM/yyyy hh:mm a"
        print(timeFormatter.string(from: datePickerOut.date))
        dateLabel.text = "\(timeFormatter.string(from: datePickerOut.date))"
        viewDatePickerBG.isHidden = true
    }
    
    
    @IBAction func datePickerOnClick(_ sender: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "dd/MM/yyyy hh:mm a"
//        print(timeFormatter.string(from: sender.date))
    }
    
    
    @IBAction func createButtonOnclick(_ sender: UIButton) {
        
        if isEdit {
            updateData()
        } else {
           
            createEvent()
        }
        
       
        
    }
    
    // MARK: - FUNCTIONS
    
    func createEvent() {
        
        //refer to the container which is set in AppDelegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        //create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //now create entity and new event records
        let eventEntity = NSEntityDescription.entity(forEntityName: "Events", in: managedContext)!
        
        //add data to newly created record
        let event = NSManagedObject(entity: eventEntity, insertInto: managedContext)
        event.setValue(eventTextview.text, forKey: "name")
        event.setValue(dateLabel.text, forKey: "date")
        
        //Now we have set all the values. The next step is to save them inside the Core Data
        
        do {
            try managedContext.save()
            secheduleNotification()
            print("saved successfully")

            self.navigationController?.popViewController(animated: true)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    func updateData(){
    
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Events")
        fetchRequest.predicate = NSPredicate(format: "name = %@", passedEvent!.name!)
        do
        {
            let test = try managedContext.fetch(fetchRequest)
   
                let objectUpdate = test[0] as! NSManagedObject
                objectUpdate.setValue(eventTextview.text, forKey: "name")
                objectUpdate.setValue(dateLabel.text, forKey: "date")
                do{
                    try managedContext.save()
                    secheduleNotification()
                    print("updatedSuccessfully")
                    self.navigationController?.popViewController(animated: true)
                }
                catch
                {
                    print(error)
                }
            }
        catch
        {
            print(error)
        }
   
    }
    
    func secheduleNotification() {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Event Reminder App"
        content.body = eventTextview.text!
        content.sound = .default
        content.userInfo = ["event title" : eventTextview.text!]
        
//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 20, repeats: false)
        let fireDate = Calendar.current.dateComponents([.day,.month,.year,.hour,.minute,.second],
//                                                           from: Date().addingTimeInterval(20)
                                                       from: datePickerOut.date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: fireDate, repeats: false)
        let request = UNNotificationRequest(identifier: dateLabel.text!, content: content, trigger: trigger)
        center.add(request) { (error) in
            if error != nil {
                print("error====\(error?.localizedDescription ?? "error local notification")")
            }
        }
    }
    
    
    func initialSetUp() {
        self.title = "Event Details"
        viewDatePickerBG.isHidden = true
        datePickerOut.preferredDatePickerStyle = .wheels
       
        if isEdit {
            createButton.setTitle("Update", for: .normal)
            eventTextview.text = passedEvent!.name
            dateLabel.text = passedEvent!.date
        } else {
            createButton.setTitle("Create", for: .normal)
        }
    }
}
