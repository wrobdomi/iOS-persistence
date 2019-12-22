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
    
    // sensors array
    var sensorsNumber: Int = 20
    var sensors: [Sensor] = []
    var archivedSensors: [Sensor] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpArchiving()
        
        // generateSensors()
        
        // saveSensors(sensors: self.sensors)
        
        getSensors()
    }
    
    
    // Setting up files paths for sensors and readings storage
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
    
    // Generating sensors
    func generateSensors(){
        let baseName: String = "S0"
        for i in 0...self.sensorsNumber-1 {
            let currentSensorName = baseName + String(i)
            let description = "Sensor number " + String(i)
            self.sensors.append(Sensor(name: currentSensorName, desc: description))
        }
        for s in self.sensors {
            s.printSensor()
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
    func getSensors() {
        
        print("Reading array of sensors from file")
        do{
            let rawdata = try Data(contentsOf: self.sensorsFileURL)
            let archived = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(rawdata) as! [Sensor]?
            self.archivedSensors = archived!
        }catch {
            print("Could not read file")
            let nsError = error as NSError
            print(nsError.localizedDescription)
        }
        
        for s in self.archivedSensors {
            s.printSensor()
        }
        
    }
    


}

