//
//  ViewController.swift
//  CoreDataSensorsReadings
//
//  Created by Dom W on 24/12/2019.
//  Copyright © 2019 Dom W. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    let sensorsNumber: Int = 20
    let readingsNumber: Int = 50000
    let maxValue: Float = 100.0
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var resultText: UITextView!
    
    let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var sensors: [Sensor] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(filePath)
        
    }

    @IBAction func onGenerateAndSave(_ sender: Any) {
        let startTime = NSDate()
        self.generateSensorsAndReadings()
        let finishTime = NSDate()
        let measuredTime = finishTime.timeIntervalSince(startTime as Date)
        timeLabel.text = "Generated in " + String(measuredTime) + " s"
    }
    
    
    @IBAction func onFindMinMaxTimestamp(_ sender: Any) {
        let startTime = NSDate()
        self.findMinAndMaxTimestamp()
        let finishTime = NSDate()
        let measuredTime = finishTime.timeIntervalSince(startTime as Date)
        timeLabel.text = "Found min and max in " + String(measuredTime) + " s"
    }
    
    @IBAction func onFindAverage(_ sender: Any) {
        let startTime = NSDate()
        self.findAvarageValue()
        let finishTime = NSDate()
        let measuredTime = finishTime.timeIntervalSince(startTime as Date)
        timeLabel.text = "Found avarage in " + String(measuredTime) + " s"
    }
    
    
    @IBAction func onFindAverageAndCountForEach(_ sender: Any) {
        let startTime = NSDate()
        self.findAvarageAndCountForEach()
        let finishTime = NSDate()
        let measuredTime = finishTime.timeIntervalSince(startTime as Date)
        timeLabel.text = "Found for each in " + String(measuredTime) + " s"
    }
    
    // generate sensors and readings
    func generateSensorsAndReadings() {
        
        let text: String = "Data generated and saved"
        
        let baseName: String = "S0"
        for i in 0...self.sensorsNumber-1 {
            let currentSensorName = baseName + String(i)
            let description = "Sensor number " + String(i)
            let sensor = Sensor(context: context)
            sensor.name = currentSensorName
            sensor.desc = description
            self.sensors.append(sensor)
        }
        
        
        for _ in 0 ... self.readingsNumber-1 {
            
            // generate random date
            let interval =  Date() - Double.random(in: 0...31556926)
            
            // generate random value
            let value = Float.random(in: 0 ... maxValue)
            
            // get random sensor
            let ranSensor = Int.random(in: 0 ... (sensorsNumber-1))
            
            let reading = Reading(context: context)
            reading.value = value
            reading.date = interval.timeIntervalSince1970
            reading.sensor = self.sensors[ranSensor]
            
        }
        
        
        do {
            try context.save()

        } catch {
            print("ERROR while saving")
        }
        
        resultText.text = text
    }
    
    func findMinAndMaxTimestamp() {
      
        let requestMin: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        let requestMax: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        
        requestMin.entity = NSEntityDescription.entity(forEntityName: "Reading", in: context)
        requestMin.resultType = NSFetchRequestResultType.dictionaryResultType
        
        requestMax.entity = NSEntityDescription.entity(forEntityName: "Reading", in: context)
        requestMax.resultType = NSFetchRequestResultType.dictionaryResultType
        
        
        let keypathExpression = NSExpression(forKeyPath: "date")
        let minExpression = NSExpression(forFunction: "min:", arguments: [keypathExpression])
        let maxExpression = NSExpression(forFunction: "max:", arguments: [keypathExpression])
        
        let keyMin = "minTimestamp"
        let keyMax = "maxTimestamp"
        
        let expressionDescriptionMin = NSExpressionDescription()
        expressionDescriptionMin.name = keyMin
        expressionDescriptionMin.expression = minExpression
        expressionDescriptionMin.expressionResultType = .doubleAttributeType
        
        let expressionDescriptionMax = NSExpressionDescription()
        expressionDescriptionMax.name = keyMax
        expressionDescriptionMax.expression = maxExpression
        expressionDescriptionMax.expressionResultType = .doubleAttributeType
        
        
        requestMin.propertiesToFetch = [expressionDescriptionMin]
        requestMax.propertiesToFetch = [expressionDescriptionMax]
        
        
        var timestampMin: Double? = nil
        var timestampMax: Double? = nil
        
        do {
            if let result = try context.fetch(requestMin) as? [[String: Double]], let dict = result.first {
                timestampMin = dict[keyMin]
            }
           
        } catch {
            print("Unable to find min timestamp")
        }
        
        do {
            if let result = try context.fetch(requestMax) as? [[String: Double]], let dict = result.first {
                timestampMax = dict[keyMax]
            }
        }catch {
            print("Unable to find max timestamp")
        }
        
        resultText.text = "Min timestamp for all readings is \(String(describing: timestampMin)) \n" + "Max timestamp for all readings is \(String(describing: timestampMax))"
    }
    
    
    func findAvarageValue(){
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Reading")
        request.resultType = NSFetchRequestResultType.dictionaryResultType
        
        let keypathExpression = NSExpression(forKeyPath: "value")
        let avgExpression = NSExpression(forFunction: "average:", arguments: [keypathExpression])
        
        let key = "avgValue"
        
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = key
        expressionDescription.expression = avgExpression
        expressionDescription.expressionResultType = .floatAttributeType
        
        request.propertiesToFetch = [expressionDescription]
        
        var average: Float? = nil
        
        do {
            let res = try context.fetch(request)
            let tempResult = res as? [[String: NSNumber]]
            if let result = tempResult, let dict = result.first {
                average = dict[key]?.floatValue
            }
        } catch {
            print("Unable to find avarage")
        }
        
        resultText.text = "Avarage value for all sensors is \(average ?? 0.0)"
    }
    
    
    func findAvarageAndCountForEach() {
        
        var textToDisplay: String = "Averages for each \n: "
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Reading")
        request.resultType = NSFetchRequestResultType.dictionaryResultType
        
        let keypathExpression = NSExpression(forKeyPath: "value")
        let maxExpression = NSExpression(forFunction: "average:", arguments: [keypathExpression])
        
        let key = "avgValue"
        
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = key
        expressionDescription.expression = maxExpression
        expressionDescription.expressionResultType = .floatAttributeType
        
        let countkeypathExpression = NSExpression(forKeyPath: "date")
        let countkey = "countValue"
        let countExpression = NSExpression(forFunction: "count:", arguments: [countkeypathExpression])
        let countExpressionDescription = NSExpressionDescription()
        countExpressionDescription.name = countkey
        countExpressionDescription.expression = countExpression
        countExpressionDescription.expressionResultType = .floatAttributeType
        
        request.propertiesToFetch = [expressionDescription, countExpressionDescription, "sensor"]
        request.propertiesToGroupBy = ["sensor"]
        request.sortDescriptors = [NSSortDescriptor(key: "sensor.name", ascending: true)]
        
        
        var averages: [(count: Float, average: Float, name: String)] = []
        do {
            let res = try context.fetch(request)
            if let result = res as? [[String: Any]] {
                result.forEach { (dict) in
                    let average = (dict[key] as! NSNumber).floatValue
                    let count = (dict[countkey] as! NSNumber).floatValue
                    let objectId = (dict["sensor"] as! NSManagedObjectID)
                    let sensor: Sensor = context.object(with: objectId) as! Sensor
                    let avg = (count: count, average: average, name: sensor.name!)
                    averages.append(avg)
                }
            }
        } catch {
            print("Unable to fetch for each")
        }
        
        for a in averages {
            textToDisplay = textToDisplay + "Sensor: \(a.name), avg \(a.average), count \(a.count) \n"
        }
        
        resultText.text = textToDisplay
        
    }
    
}

