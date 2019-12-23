//
//  Sensor.swift
//  ArchivingSensorsReadings
//
//  Created by Dom W on 22/12/2019.
//  Copyright © 2019 Dom W. All rights reserved.
//

import Foundation

class Sensor: NSObject, NSCoding{

    var name: String
    var desc: String
    
    // memberwise initializer
    init(name: String, desc: String){
        self.name = name
        self.desc = desc
    }
    
    // MARK: NSCoding
    // decoding from file
    required convenience init?(coder decoder: NSCoder) {
        guard
            let name = decoder.decodeObject(forKey: "name") as? String,
            let desc = decoder.decodeObject(forKey: "desc") as? String
        else {
            return nil
        }
        
        self.init(
            name: name,
            desc: desc
        )
    }
    
    // encoding to file
    func encode(with coder: NSCoder) {
        coder.encode(self.name, forKey: "name")
        coder.encode(self.desc, forKey: "desc")
    }
    
    func printSensor() -> String{
        print("Sensor \(name): \(desc)")
        return "Sensor \(name): \(desc) \n"
    }
    
}
