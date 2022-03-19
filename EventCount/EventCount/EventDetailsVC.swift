//
//  EventDetailsVC.swift
//  EventCount
//
//  Created by Alphonsa Varghese on 14/03/22.
//

import UIKit

class EventDetailsVC: UIViewController {
    // MARK: - OUTLETS
    
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var secLabel: UILabel!
    
    // MARK: - VARIABLES
    var EventDataModel = Events()
    var eventDate : NSDate?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(EventDataModel.date!)
        setUpTime()
    }
    
    // MARK: - ACTIONS
    
    // MARK: - FUNCTIONS
    
    func setUpTime() {
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = "dd-MM-yyyy hh:mm a"
        eventDate = dateFormate.date(from: EventDataModel.date!) as NSDate?
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDownTime), userInfo: nil, repeats: true)
    }
    
    @objc func countDownTime() {
        let currentDate = Date()
        let diffDateComponents = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: currentDate, to: eventDate! as Date)
            
        let countdown = "Days: \(diffDateComponents.day), Hours: \(diffDateComponents.hour), Minutes: \(diffDateComponents.minute), Seconds: \(diffDateComponents.second)"
      
        
        let day = diffDateComponents.day
        let hours = diffDateComponents.hour
        let mins = diffDateComponents.minute
        let secs = diffDateComponents.second
        dayLabel.text = "\(day!) Days"
        hourLabel.text = "\(hours!) Hrs"
        minLabel.text = "\(mins!) Mins"
        secLabel.text = "\(secs!) Secs"
        
    }

}
