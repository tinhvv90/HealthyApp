//
//  StepsViewController.swift
//  StepWalk
//
//  Created by ptud2 on 11/04/2019.
//  Copyright © 2019 Agency. All rights reserved.
//

import UIKit
import Charts
import CoreMotion

class StepsViewController: UIViewController {

    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var weeklyStepsLineChartView: LineChartView!
    
    var stepEmtry = PieChartDataEntry(value: 0)
    var stepGoal = PieChartDataEntry(value: 0)
    
    var goalStep: Double = 5000
    
    var days:[String] = []
    var stepsTaken:[Int] = []
    let activityManager = CMMotionActivityManager()
    let pedoMeter = CMPedometer()
    
    var cnt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChart()
        getDataForLastWeek()
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
        pieChartView.chartDescription?.text = "Steps Count today"
        stepEmtry.label = "Steps today"
        stepGoal.value = goalStep
        stepGoal.label = "Goal"
        updatePieChartData()
        
        weeklyStepsLineChartView.chartDescription?.enabled = false
        weeklyStepsLineChartView.setScaleEnabled(false)
        weeklyStepsLineChartView.leftAxis.enabled=false
        weeklyStepsLineChartView.rightAxis.enabled=false
        
        weeklyStepsLineChartView.xAxis.drawGridLinesEnabled = false
        weeklyStepsLineChartView.xAxis.labelPosition = .bottom
        weeklyStepsLineChartView.xAxis.labelFont = UIFont(name:"HelveticaNeue-Bold", size: 13.0)!
        weeklyStepsLineChartView.legend.enabled = false
    }
    
    func updatePieChartData() {
        let chartDataSet = PieChartDataSet(values: [stepEmtry, stepGoal], label: "Steps")
        let chartData = PieChartData(dataSet: chartDataSet)
        
        chartDataSet.colors = [UIColor.blue, UIColor.gray]
        pieChartView.data = chartData
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
        
        
        weeklyStepsLineChartView.data = data //finally - it adds the chart data to the chart and causes an update

        let xAxisValue = weeklyStepsLineChartView.xAxis
        
        //  xAxisValue.valueFormatter = axisFormatDelegate
        xAxisValue.valueFormatter = IndexAxisValueFormatter(values: days)
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

                            if self.days.count == 7 {
                                print(self.stepsTaken)
                                self.stepEmtry.value = Double(self.stepsTaken.last ?? 0)
                                self.updateGraph()
                                self.updatePieChartData()
                                self.view.reloadInputViews()
                                self.pieChartView.reloadInputViews()
                                self.weeklyStepsLineChartView.reloadInputViews()
                            }
                        }
                    })
                }
            }
        }
    }
}

