//
//  ViewController.swift
//  StepWalk
//
//  Created by ptud2 on 10/04/2019.
//  Copyright © 2019 Agency. All rights reserved.
//

import UIKit
import CoreMotion
import Dispatch

class ViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stepsCount: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    private let activityManager = CMMotionActivityManager()
    private let pedometer = CMPedometer()
    private var shouldStartUpdating: Bool = false
    private var startDate: Date? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()
        startButton.addTarget(self, action: #selector(didTapStartButton), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let startDate = startDate else { return }
        updateStepsCountLabelUsing(startDate: startDate)
    }
    
    @objc private func didTapStartButton() {
        shouldStartUpdating = !shouldStartUpdating
        shouldStartUpdating ? (onStart()) : (onStop())
    }

    private func startTrackingActivityType() {
        activityManager.startActivityUpdates(to: OperationQueue.main) {
            [weak self] (activity: CMMotionActivity?) in
            
            guard let activity = activity else { return }
            DispatchQueue.main.async {
                if activity.walking {
                    self?.typeLabel.text = "Walking"
                } else if activity.stationary {
                    self?.typeLabel.text = "Stationary"
                } else if activity.running {
                    self?.typeLabel.text = "Running"
                } else if activity.automotive {
                    self?.typeLabel.text = "Automotive"
                }
            }
        }
    }
    
    private func startCountingSteps() {
        pedometer.startUpdates(from: Date()) {
            [weak self] pedometerData, error in
            guard let pedometerData = pedometerData, error == nil else { return }
            
            DispatchQueue.main.async {
                self?.stepsCount.text = pedometerData.numberOfSteps.stringValue
                
                let metter = pedometerData.distance
        
                self?.distanceLabel.text = "\(metter?.doubleValue ?? 0 / 100000)"
            }
        }
    }

    private func startUpdating() {
        if CMMotionActivityManager.isActivityAvailable() {
            startTrackingActivityType()
        }
        
        if CMPedometer.isStepCountingAvailable() {
            startCountingSteps()
        }
    }
    
    private func onStart() {
        startButton.setTitle("Stop", for: .normal)
        startDate = Date()
        checkAuthorizationStatus()
        startUpdating()
    }
    
    private func onStop() {
        startButton.setTitle("Start", for: .normal)
        startDate = nil
        stopUpdating()
    }
    
    private func checkAuthorizationStatus() {
        switch CMMotionActivityManager.authorizationStatus() {
        case CMAuthorizationStatus.denied:
            onStop()
            typeLabel.text = "Not available"
            stepsCount.text = "Not available"
        default:break
        }
    }
    
    private func stopUpdating() {
        activityManager.stopActivityUpdates()
        pedometer.stopUpdates()
        pedometer.stopEventUpdates()
    }

    private func updateStepsCountLabelUsing(startDate: Date) {
        pedometer.queryPedometerData(from: startDate, to: Date()) {
            [weak self] pedometerData, error in
            if let error = error {
                print(error)
            } else if let pedometerData = pedometerData {
                DispatchQueue.main.async {
                    self?.stepsCount.text = String(describing: pedometerData.numberOfSteps)
                    
                    let metter = pedometerData.distance
                    
                    self?.distanceLabel.text = "\(metter?.doubleValue ?? 0 / 100000)"
                }
            }
        }
    }
}

