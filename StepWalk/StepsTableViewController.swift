//
//  StepsTableViewController.swift
//  StepWalk
//
//  Created by ptud2 on 12/04/2019.
//  Copyright © 2019 Agency. All rights reserved.
//

import UIKit
import Charts
import CoreMotion

class StepsTableViewController: UITableViewController {

    @IBOutlet weak var stepsCircleView: CircleViewProgress!
    @IBOutlet weak var stepsNumber: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var weekStepsChartLine: LineChartView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var pointChartLine: LineChartView!
    
    var stepEmtry = 0.0
    var stepGoal = 0.0
    var distance = 0.0
    
    var goalStep: Double = 5000
    
    var days:[String] = []
    var stepsTaken:[Int] = []
    let activityManager = CMMotionActivityManager()
    let pedoMeter = CMPedometer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startUpdating()
        setupChart()
        goalLabel.text = "MUC TIEU: \(Int(goalStep) / 1000) Km"
        stepsNumber.text = "\(Int(stepEmtry))"
        self.distanceLabel.text = "Da Di: \(self.roundDouble(a: distance / 1000)) Km"
    }
    
    private func startUpdating() {
        if CMPedometer.isStepCountingAvailable() {
            getDataForLastWeek()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStep()
    }
    
    func updateStep() {
        pedoMeter.startUpdates(from: Date()) { (data, error) in
            self.getDataForLastWeek()
        }
    }
    
    func setupChart() {
        weekStepsChartLine.chartDescription?.enabled = false
        weekStepsChartLine.setScaleEnabled(false)
        weekStepsChartLine.leftAxis.enabled=false
        weekStepsChartLine.rightAxis.enabled=false
        
        weekStepsChartLine.xAxis.drawGridLinesEnabled = false
        weekStepsChartLine.xAxis.labelPosition = .bottom
        weekStepsChartLine.xAxis.labelFont = UIFont(name:"HelveticaNeue-Bold", size: 13.0)!
        weekStepsChartLine.legend.enabled = false
    }
    
    func updateGraph() {
        var lineChartEntry  = [ChartDataEntry]() //this is the Array that will eventually be displayed on the graph.
        
        //here is the for loop
        for i in 0..<stepsTaken.count {
            
            let value = ChartDataEntry(x: Double(i), y: Double(stepsTaken[i]), data: days as AnyObject?) // here we set the X and Y status in a data chart entry
            lineChartEntry.append(value) // here we add it to the data set
        }
        
        let line1 = LineChartDataSet(values: lineChartEntry, label: "") //Here we convert lineChartEntry to a LineChartDataSet
        
        //  line1.colors = [NSUIColor.blue] //Sets the colour to blue
        line1.drawCircleHoleEnabled = true
        
        line1.circleHoleColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        line1.setColor(.red)
        line1.setCircleColor(.red)
        
        /// The radius of the drawn circles.
        line1.circleRadius = 4
        
        /// The hole radius of the drawn circles
        line1.circleHoleRadius = 3
        
        line1.lineWidth = 0.3
        line1.valueFont = .systemFont(ofSize: 9)
        line1.formLineWidth = 0.3
        line1.formSize = 15
        
        let gradientColors = [ChartColorTemplates.colorFromString("#F01204").cgColor,
                              ChartColorTemplates.colorFromString("#00ff0000").cgColor
        ]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
        
        line1.fillAlpha = 1
        line1.fill = Fill(linearGradient: gradient, angle: 90) //.linearGradient(gradient, angle: 90)
        line1.drawFilledEnabled = true
        
        let data = LineChartData() //This is the object that will be added to the chart
        data.addDataSet(line1) //Adds the line to the dataSet
        
        
        weekStepsChartLine.data = data //finally - it adds the chart data to the chart and causes an update
        
        let xAxisValue = weekStepsChartLine.xAxis
        
        //  xAxisValue.valueFormatter = axisFormatDelegate
        xAxisValue.valueFormatter = IndexAxisValueFormatter(values: days)
        
        self.view.setNeedsDisplay()
    }
    
    func getDataForLastWeek() {
        if CMPedometer.isStepCountingAvailable() {
            self.days = []
            self.stepsTaken = []
            let queue = DispatchQueue(label: "com.example.my-serial-queue")
            
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            queue.sync {
                
                for day in 0...6 {
                    let fromDate = Date(timeIntervalSinceNow: Double(-7 + day) * 86400)
                    let toDate = Date(timeIntervalSinceNow: Double(-7 + day + 1) * 86400)
                    
                    let dateStr = formatter.string(from: toDate)
                    
                    self.pedoMeter.queryPedometerData(from: fromDate, to: toDate, withHandler: { (data : CMPedometerData!, error) in
                        if error == nil {
                            print("\(dateStr) : \(data.numberOfSteps)")
                            self.days.append(dateStr)
                            self.stepsTaken.append(Int(data.numberOfSteps))
                            print("Days :\(self.days)")
                            print("Steps :\(self.stepsTaken)")
                            self.distance = data.distance?.doubleValue ?? 0.0
                            if self.days.count == 7 {
                                print(self.stepsTaken)
                                self.stepEmtry = Double(self.stepsTaken.last ?? 0)
                                self.setupProgressView()
                            }
                        }
                    })
                }
            }
        }
    }
    
    func setupProgressView() {
        DispatchQueue.main.async {
            self.updateGraph()
            self.stepsCircleView.progress = self.distance / self.goalStep
            self.stepsNumber.text = "\(Int(self.stepEmtry))"
            let distanceKm = self.distance / 1000
            self.distanceLabel.text = "Da Di: \(self.roundDouble(a: distanceKm)) Km"
            self.tableView.reloadData()
            self.tableView.setNeedsDisplay()
        }
    }
    
    func roundDouble(a:Double) -> Double {
        let mu = pow(10.0,2.0)
        let r = round( a * mu ) / mu
        return r
    }
}
