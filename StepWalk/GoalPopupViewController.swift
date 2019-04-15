//
//  GoalPopupViewController.swift
//  StepWalk
//
//  Created by ptud2 on 12/04/2019.
//  Copyright © 2019 Agency. All rights reserved.
//

import UIKit

protocol GoalPopupViewControllerDelegate: class {
    func getGoalOfDistance(distance: String)
}

class GoalPopupViewController: UIViewController {

    @IBOutlet weak var pickerView: UIPickerView!
    
    weak var delegate : GoalPopupViewControllerDelegate?
    
    var goalSteps = ["5 Km", "10 Km"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
}

extension GoalPopupViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return goalSteps.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return goalSteps[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.getGoalOfDistance(distance: goalSteps[row])
    }
}
