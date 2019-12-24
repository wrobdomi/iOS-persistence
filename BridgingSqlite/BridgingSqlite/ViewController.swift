//
//  ViewController.swift
//  BridgingSqlite
//
//  Created by Dom W on 23/12/2019.
//  Copyright © 2019 Dom W. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var db: OpaquePointer? = nil
    
    // sensors
    let sensorsNumber: Int = 20
    
    // readings
    let readingsNumber: Int = 50000
    let maxValue: Float = 100
    
    
    // labels
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var textResults: UITextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpDB()
        
    }
    
    @IBAction func onGenerateAndSave(_ sender: Any) {
        let startTime = NSDate()
        generateAndSaveSensorsAndReadings()
        let finishTime = NSDate()
        let measuredTime = finishTime.timeIntervalSince(startTime as Date)
        timeLabel.text = "Data generated and saved in " + String(measuredTime) + " s"
        textResults.text = "Values saved in db."
    }
    
    
    @IBAction func onFindMinManTimestamp(_ sender: Any) {
        let startTime = NSDate()
        findMinMaxTimestamp()
        let finishTime = NSDate()
        let measuredTime = finishTime.timeIntervalSince(startTime as Date)
        timeLabel.text = "Min max time found in " + String(measuredTime) + " s"
    }
    
    
    @IBAction func onFindAvarageValue(_ sender: Any) {
        let startTime = NSDate()
        findAverageValue()
        let finishTime = NSDate()
        let measuredTime = finishTime.timeIntervalSince(startTime as Date)
        timeLabel.text = "Average found in " + String(measuredTime) + " s"
    }
    
    
    @IBAction func onFindAvarageForEach(_ sender: Any) {
        let startTime = NSDate()
        findAvarageAndCountForEach()
        let finishTime = NSDate()
        let measuredTime = finishTime.timeIntervalSince(startTime as Date)
        timeLabel.text = "Average for each found in: " + String(measuredTime) + " s"
    }
    
    
    func setUpDB() {
        // get documents folder for the app
        let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        
        // get url to db file
        let dbFilePath = NSURL(fileURLWithPath: docDir!).appendingPathComponent("database.db")?.path
        
        print(dbFilePath!)
        
        // open and create new db
        if sqlite3_open(dbFilePath, &db) == SQLITE_OK {
            print("Open db success")
        } else {
            print("Open db failed")
        }
        
        let createTableSensorsQuery = """
            CREATE TABLE IF NOT EXISTS Sensors(
                name TEXT PRIMARY KEY,
                desc TEXT
            );
        """
        
        let createTableReadingsQuery = """
            CREATE TABLE IF NOT EXISTS Readings(
                name TEXT PRIMARY KEY REFERENCES Sensors(name),
                timestamp INTEGER,
                value REAL
            );
        """
        
        sqlite3_exec(db, createTableSensorsQuery, nil, nil, nil)
        sqlite3_exec(db, createTableReadingsQuery, nil, nil, nil)
        
    }
    
    
    func generateAndSaveSensorsAndReadings() {
        
        // generate and save sensors
        let baseName: String = "S0"
        for i in 0 ... self.sensorsNumber-1 {
            let currentSensorName = baseName + String(i)
            let description = "Sensor number " + String(i)
            
            // save sensor in db
            sqlite3_exec(db, "INSERT INTO Sensors (name, desc) VALUES ('\(currentSensorName)', '\(description)');", nil, nil, nil)
        }
        
        // generate and save readings
        var insertReadingsQuery = "INSERT INTO Readings (name, timestamp, value) VALUES "
        
        for _ in 0 ... self.readingsNumber-1 {
            
            // generate random date
            let date = (Date() - Double.random(in: 0...31556926)).timeIntervalSince1970
            
            // generate random value
            let value = Float.random(in: 0 ... maxValue)
            
            // get random sensor
            let ranSensor = Int.random(in: 0 ... (sensorsNumber-1))
            let ranSensorName = "S0" + String(ranSensor)
            
            insertReadingsQuery = insertReadingsQuery + "('\(ranSensorName)', \(date), \(value)), "
        }
        var croppedQuery = insertReadingsQuery.dropLast(2)
        croppedQuery = croppedQuery + ";"
        sqlite3_exec(db, String(croppedQuery), nil, nil, nil)
        
    }
    
    
    func findMinMaxTimestamp() {
        
        var timestampMin: Double = 0
        var timestampMax: Double = 0
        
        var stmtMin: OpaquePointer? = nil
        var stmtMax: OpaquePointer? = nil
        
        let selectMin = "SELECT MIN(timestamp) FROM Readings;"
        let selectMax = "SELECT MAX(timestamp) FROM Readings;"
        
        sqlite3_prepare_v2(db, selectMin, -1, &stmtMin, nil)
        while sqlite3_step(stmtMin) == SQLITE_ROW {
            timestampMin = Double(sqlite3_column_double(stmtMin, 0))
        }
        sqlite3_finalize(stmtMin)
        
        sqlite3_prepare_v2(db, selectMax, -1, &stmtMax, nil)
        while sqlite3_step(stmtMax) == SQLITE_ROW {
            timestampMax = Double(sqlite3_column_double(stmtMax, 0))
        }
        sqlite3_finalize(stmtMax)
        
        textResults.text = "Min: " + String(timestampMin) + "\n Max: " + String(timestampMax)
        
    }
    
    
    func findAverageValue() {
        
        var average: Float = 0.0
        
        var stmt: OpaquePointer? = nil
        
        sqlite3_prepare_v2(db, "SELECT avg(value) FROM Readings", -1, &stmt, nil)
        
        while sqlite3_step(stmt) == SQLITE_ROW {
            average = Float(sqlite3_column_double(stmt, 0))
        }
        sqlite3_finalize(stmt)
        
        textResults.text = "Avarage value: " + String(average)

    }
    
    
    func findAvarageAndCountForEach() {
        
        var resultText: String = ""
        
        var stmt: OpaquePointer? = nil
        
        sqlite3_prepare_v2(db, "SELECT avg(value), count(value), name FROM Readings GROUP BY name", -1, &stmt, nil)
        
        while sqlite3_step(stmt) == SQLITE_ROW {
            let average = Float(sqlite3_column_double(stmt, 0))
            let count = Float(sqlite3_column_double(stmt, 1))
            let name = String(cString: sqlite3_column_text(stmt, 2))
            resultText = resultText + "Sensor \(name): average \(average), count \(count) \n"
        }
        
        textResults.text = resultText
        
        sqlite3_finalize(stmt)
        
    }

    
}

