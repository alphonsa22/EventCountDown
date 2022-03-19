//
//  ArchiedEventVC.swift
//  EventCount
//
//  Created by Alphonsa Varghese on 19/03/22.
//

import UIKit
import CoreData

class ArchiedEventVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var archieveTableview: UITableView!
    
    // MARK: - VARIABLES
    var ArchieveDataModelArry = [Archive]()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        initialSetUp()
    }

    // MARK: - ACTION
    
    
    //MARK:- DELEGATES
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ArchieveDataModelArry.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventListCell") as? EventListCell else {
            return UITableViewCell()
        }
        cell.configArchieveCell(item: ArchieveDataModelArry[indexPath.row])
        return cell
        
    }

    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    // MARK: - FUNCTION
    
    func RetriveArchive() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Prepare the request of type NSFetchRequest  for the entity
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Events")
        let eventRequest: NSFetchRequest<Archive> = Archive.fetchRequest()
        do {
            var results = try managedContext.fetch(eventRequest)
            ArchieveDataModelArry = try managedContext.fetch(eventRequest)
            print(results.count)
            print("retrieved successfully")
            self.archieveTableview.reloadData()
        } catch {
                print("Could not load save data: \(error.localizedDescription)")
        }

    }

    func initialSetUp() {
        archieveTableview.delegate = self
        archieveTableview.dataSource = self
        self.title = "Archied Events"
        RetriveArchive()
    }
}
