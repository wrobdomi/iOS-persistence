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
    var readingsNumber: Int = 15
    var readings: [Reading] = []
    var archivedReadings: [Reading] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpArchiving()
        
        generateSensorsAndReadings()
        
        saveSensors(sensors: self.sensors)
        
        readSensors()
        
        saveReadings(readings: self.readings)
        
        readReadings()
        
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
    
    // generate sensors
    func generateSensorsAndReadings(){
        let baseName: String = "S0"
        for i in 0...self.sensorsNumber-1 {
            let currentSensorName = baseName + String(i)
            let description = "Sensor number " + String(i)
            self.sensors.append(Sensor(name: currentSensorName, desc: description))
        }
        
        // print sensors for debugging
        for s in self.sensors {
            s.printSensor()
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
            readings[r].printReading()
        }
        
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
    


}

