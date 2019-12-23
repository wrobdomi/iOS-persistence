//
//  ViewController.swift
//  ArchivingSensorsReadings
//
//  Created by Dom W on 20/12/2019.
//  Copyright © 2019 Dom W. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var baseDirURL: URL!
    var sensorsFileURL: URL!
    var readingsFileURL: URL!
    
    // sensors
    var sensorsNumber: Int = 20
    var sensors: [Sensor] = []
    var archivedSensors: [Sensor] = []
    
    // readings
    var maxValue: Float = 100.0
    var readingsNumber: Int = 50000
    var readings: [Reading] = []
    var archivedReadings: [Reading] = []
    
    @IBOutlet weak var textDisplay: UITextView!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpArchiving()
        
    }
    
    
    @IBAction func onGenerateData(_ sender: Any) {
        let startTime = NSDate()
        self.generateSensorsAndReadings()
        saveSensors(sensors: self.sensors)
        saveReadings(readings: self.readings)
        let finishTime = NSDate()
        let measuredTime = finishTime.timeIntervalSince(startTime as Date)
        timeLabel.text = "Generated in " + String(measuredTime) + " s"
        // print(measuredTime)
    }
    
    @IBAction func onFindMinMaxTimestamp(_ sender: Any) {
        let startTime = NSDate()
        self.findMinAndMaxTimestamp()
        let finishTime = NSDate()
        let measuredTime = finishTime.timeIntervalSince(startTime as Date)
        timeLabel.text = "Found min and max in " + String(measuredTime) + " s"
        // print(measuredTime)
    }
    
    
    @IBAction func onCalculateAvarage(_ sender: Any) {
        let startTime = NSDate()
        self.findAvarageValue()
        let finishTime = NSDate()
        let measuredTime = finishTime.timeIntervalSince(startTime as Date)
        timeLabel.text = "Found avarage in " + String(measuredTime) + " s"
    }
    
    
    @IBAction func onCalculateForEach(_ sender: Any) {
        let startTime = NSDate()
        self.findAvarageAndCountForEach()
        let finishTime = NSDate()
        let measuredTime = finishTime.timeIntervalSince(startTime as Date)
        timeLabel.text = "Found for each in " + String(measuredTime) + " s"
    }
    
    
    // setting up files paths for sensors and readings storage
    func setUpArchiving(){
        
        // get name of the directory where you can store data for this app
        self.baseDirURL = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        print(baseDirURL)
        
        // sensors file
        self.sensorsFileURL = self.baseDirURL.appendingPathComponent("sensors")
        print(sensorsFileURL)
        
        // readings file
        self.readingsFileURL = self.baseDirURL.appendingPathComponent("readings")
        print(readingsFileURL)
        
    }
    
    // generate sensors and readings
    func generateSensorsAndReadings(){
        
        var text: String = "Sample generated data: \n"
        
        let baseName: String = "S0"
        for i in 0...self.sensorsNumber-1 {
            let currentSensorName = baseName + String(i)
            let description = "Sensor number " + String(i)
            self.sensors.append(Sensor(name: currentSensorName, desc: description))
        }
        
        // print sensors for debugging
        for s in self.sensors {
            text = text + s.printSensor()
        }
        
        for _ in 0 ... self.readingsNumber-1 {
            
            // generate random date
            let interval = TimeInterval.random(in: 0 ... 10000)
            let date = Date.init(timeIntervalSinceNow: interval)
            
            // generate random value
            let value = Float.random(in: 0 ... maxValue)
            
            // get random sensor
            let ranSensor = Int.random(in: 0 ... (sensorsNumber-1))
            
            self.readings.append(Reading(sensor: self.sensors[ranSensor], value: value, date: date))
            
        }
       
        // print first ten readings for debugging...
        for r in 0 ... 10 {
            text = text + readings[r].printReading()
        }
        
        textDisplay.text = text
    }
    
    // save sensors in file
    func saveSensors(sensors: [Sensor]){
        
        print("Saving array of sensors to file")
        do{
            let dataToSave = try NSKeyedArchiver.archivedData(withRootObject: sensors, requiringSecureCoding: false)
            try dataToSave.write(to: self.sensorsFileURL)
        }catch{
            print("Could not write sensors to file")
            let nsError = error as NSError
            print(nsError.localizedDescription)
        }
    }
    
    // read sensors from file
    func readSensors() {
        
        self.archivedSensors = []
        
        print("Reading array of sensors from file")
        do{
            let rawdata = try Data(contentsOf: self.sensorsFileURL)
            let archived = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(rawdata) as! [Sensor]?
            self.archivedSensors = archived!
        }catch {
            print("Could not read file sensors")
            let nsError = error as NSError
            print(nsError.localizedDescription)
        }
        
        for s in self.archivedSensors {
            s.printSensor()
        }
        
    }
    
    
    // save readings to file
    func saveReadings(readings: [Reading]) {
        print("Saving array of readings to file")
        do{
            let dataToSave = try NSKeyedArchiver.archivedData(withRootObject: readings, requiringSecureCoding: false)
            try dataToSave.write(to: self.readingsFileURL)
        }catch{
            print("Could not write readings to file")
            let nsError = error as NSError
            print(nsError.localizedDescription)
        }
    }
    
    
    // read readings from file
    func readReadings() {
        
        self.archivedReadings = []
        
        print("Reading array of readings from file")
        
        do{
     
            let rawdata = try Data(contentsOf: self.readingsFileURL)
            let archived = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(rawdata) as! [Reading]?
            self.archivedReadings = archived!
        }catch {
            print("Could not read file readings")
            let nsError = error as NSError
            print(nsError.localizedDescription)
        }
        
        print("Reading readings from file finished...")
        
        // print first ten readings for debugging...
        for r in 0 ... 10 {
            self.archivedReadings[r].printReading()
        }
        
    }
    
    
    func findMinAndMaxTimestamp() {
        
        var maxTimestamp: Date
        var minTimestamp: Date
        
        minTimestamp = Date.init(timeIntervalSinceNow: 0)
        maxTimestamp = Date.init(timeIntervalSinceNow: 12000)
        
        self.readReadings()
        
        for r in self.archivedReadings {
            if r.date < minTimestamp {
                minTimestamp = r.date
            }
            if r.date > maxTimestamp {
                maxTimestamp = r.date
            }
        }
        
        textDisplay.text = "Min timestamp for all readings is \(minTimestamp) \n" + "Max timestamp for all readings is \(maxTimestamp)"
    }
    
    
    func findAvarageValue() {
        var avarage: Float = 0
        
        self.readReadings()
        
        for r in self.archivedReadings {
            avarage = avarage + r.value
        }
        
        let avg = avarage / Float(self.archivedReadings.count)
        
        textDisplay.text = "Avarage value for all sensors is \(avg)"
    }
    
    func findAvarageAndCountForEach() {
        
        var textToPrint: String = ""
        
        var avarageDictionary: [String:Float] = [:]
        var countDictionary: [String:Int] = [:]
        
        self.readSensors()
        self.readReadings()
        
        for s in self.archivedSensors {
            avarageDictionary[s.name] = 0.0
            countDictionary[s.name] = 0
        }
        
        for r in self.archivedReadings {
            avarageDictionary[r.sensor.name] = avarageDictionary[r.sensor.name]! + r.value
            countDictionary[r.sensor.name] = countDictionary[r.sensor.name]! + 1
        }
        
        for s in self.archivedSensors {
            
            if countDictionary[s.name] != 0 {
                avarageDictionary[s.name] = avarageDictionary[s.name]! / Float(countDictionary[s.name]!)
            }
            
            textToPrint = textToPrint + "Sensor \(s.name), avarage \(String(describing: avarageDictionary[s.name]!)), count \(String(describing: countDictionary[s.name]!)) \n"
            
        }
        
        textDisplay.text = textToPrint
        
    }
    


}

