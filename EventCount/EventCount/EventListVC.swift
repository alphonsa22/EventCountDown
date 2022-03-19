//
//  EventListVC.swift
//  EventCount
//
//  Created by Alphonsa Varghese on 14/03/22.
//

import UIKit
import CoreData

class EventListVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
  
    
    //MARK:- OUTLETS
    
    @IBOutlet weak var eventTableView: UITableView!
    
    //MARK:- VARIABLES
    var EventDataModelArry = [Events]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        initialSetUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        RetriveEvents()
    }
    //MARK:- DELEGATES
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EventDataModelArry.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventListCell") as? EventListCell else {
            return UITableViewCell()
        }
        cell.configCell(item: EventDataModelArry[indexPath.row])
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal,
                                         title: "Delete") { [weak self] (action, view, completionHandler) in
            self?.handleDelete(index: indexPath.row)
                                            completionHandler(true)
        }
        delete.backgroundColor = .systemRed
        let configuration = UISwipeActionsConfiguration(actions: [delete])
        return configuration

    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal,
                                         title: "Edit") { [weak self] (action, view, completionHandler) in
            self?.handleEdit(passedEvent: self!.EventDataModelArry[indexPath.row])
                                            completionHandler(true)
        }
        edit.backgroundColor = .systemGreen
        let configuration = UISwipeActionsConfiguration(actions: [edit])
        return configuration
    }
    
    private func handleDelete(index:Int) {
        self.deleteEvent(eventName: EventDataModelArry[index].name ?? "", eventDate: EventDataModelArry[index].date!)
    }
    
    private func handleEdit(passedEvent : Events) {
        print("Edit the event")
        guard let vc = storyboard?.instantiateViewController(identifier: "EventAddEditVC") as? EventAddEditVC else {
            return
        }
        vc.isEdit = true
        vc.passedEvent = passedEvent
        self.navigationController?.pushViewController(vc, animated: false)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
        
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(identifier: "EventDetailsVC") as? EventDetailsVC else {
            return
        }
        vc.EventDataModel = EventDataModelArry[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    //MARK:- ACTIONS
    
    @IBAction func archiveClick(_ sender: UIBarButtonItem) {
    
        guard let vc = storyboard?.instantiateViewController(identifier: "ArchiedEventVC") as? ArchiedEventVC else {
            return
        }
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @IBAction func addEventClick(_ sender: UIBarButtonItem) {
        
        guard let vc = storyboard?.instantiateViewController(identifier: "EventAddEditVC") as? EventAddEditVC else {
            return
        }
        vc.isEdit = false
//        vc.passedEvent = passedEvent
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    //MARK:- FUNCTIONS
    
    func initialSetUp() {
        eventTableView.delegate = self
        eventTableView.dataSource = self
    }
    
    func RetriveEvents() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Prepare the request of type NSFetchRequest  for the entity
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Events")
        let eventRequest: NSFetchRequest<Events> = Events.fetchRequest()
        do {
            var results = try managedContext.fetch(eventRequest)
//            EventDataModelArry = try managedContext.fetch(eventRequest)
            print(results.count)
            print("retrieved successfully")
//            print(EventDataModelArry[0].name as Any)
            EventDataModelArry.removeAll()
            for item in results {
                let dateFormate = DateFormatter()
                dateFormate.dateFormat = "dd/MM/yyyy hh:mm a"
                let dateFrom = dateFormate.date(from: item.date!)
                if dateFrom! > Date() {
                    EventDataModelArry.append(item)
                } else {
//                    createEvent(eventname: item.name!, eventDate: item.date!)
                    deleteEvent(eventName: item.name!, eventDate: item.date!)
                }
            }
            
                    self.eventTableView.reloadData()
        } catch {
                print("Could not load save data: \(error.localizedDescription)")
        }

    }
    
    func deleteEvent(eventName:String,eventDate:String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Events")
        fetchRequest.predicate = NSPredicate(format: "name = %@", eventName)
        do
        {
            let test = try managedContext.fetch(fetchRequest)
            
            let objectToDelete = test[0] as! NSManagedObject
            managedContext.delete(objectToDelete)
            
            do{
                try managedContext.save()
                print("successfully deleted")
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [eventDate])
                self.RetriveEvents()
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
    
    
    func createEvent(eventname:String,eventDate:String) {
        
        //refer to the container which is set in AppDelegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        //create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //now create entity and new event records
        let eventEntity = NSEntityDescription.entity(forEntityName: "Archive", in: managedContext)!
        
        //add data to newly created record
        let event = NSManagedObject(entity: eventEntity, insertInto: managedContext)
        event.setValue(eventname, forKey: "name")
        event.setValue(eventDate, forKey: "date")
        
        //Now we have set all the values. The next step is to save them inside the Core Data
        
        do {
            try managedContext.save()
            print("achieve saved successfully")
          
           
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
}


class EventListCell : UITableViewCell {
    
    @IBOutlet weak var eventNameLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    func configCell(item:Events) {
        eventNameLabel.text = item.name
        dateLabel.text = item.date
    }
    
    
    func configArchieveCell(item:Archive) {
        eventNameLabel.text = item.name ?? ""
        dateLabel.text = item.date ?? ""
    }
}

