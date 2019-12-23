//
//  Reading.swift
//  ArchivingSensorsReadings
//
//  Created by Dom W on 22/12/2019.
//  Copyright © 2019 Dom W. All rights reserved.
//

import Foundation


class Reading: NSObject, NSCoding{
    
    var sensor: Sensor
    var date: Date
    var value: Float
    
    // memberwise initializer
    init(sensor: Sensor, value: Float, date: Date){
        self.sensor = sensor
        self.date = date
        self.value = value
    }
    
    // MARK: NSCoding
    // decoding from file
    required convenience init?(coder decoder: NSCoder) {
        guard
            let sensor = decoder.decodeObject(forKey: "sensor") as? Sensor,
            let date = decoder.decodeObject(forKey: "date") as? Date,
            let value = decoder.decodeFloat(forKey: "value") as Float?
            else {
                return nil
        }
        
        self.init(
            sensor: sensor,
            value: value,
            date: date
        )
    }
    
    // encoding to file
    func encode(with coder: NSCoder) {
        coder.encode(self.sensor, forKey: "sensor")
        coder.encode(self.date, forKey: "date")
        coder.encode(self.value, forKey: "value")
    }
    
    func printReading() -> String {
        // print("Reading reading:")
        var text: String = ""
        text = self.sensor.printSensor()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .full
        print("Reading: \(self.value), " + dateFormatter.string(from: self.date))
        return text + ", Reading: \(self.value), " + dateFormatter.string(from: self.date) + "\n"
    }
    
}
