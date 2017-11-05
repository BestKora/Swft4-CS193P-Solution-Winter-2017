//
//  ViewController.swift
//  Calculator
//
//  Created by Tatiana Kornilova on 3/8/17.
//  All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    @IBOutlet weak var tochka: UIButton!{
        didSet {
            tochka.setTitle(decimalSeparator, for: .normal)
        }
    }
    
    @IBOutlet weak var displayM: UILabel!
    @IBOutlet weak var radians: UIButton!{
        didSet {
            let title = brain.isRadian ? "radians" : "degrees"
            radians.setTitle(title, for: .normal)
        }
    }
    
    let decimalSeparator = formatter.decimalSeparator ?? "."
    var userInTheMiddleOfTyping = false
    
    @IBAction func touchDigit(_ sender: UIButton) {
        if let digit = sender.currentTitle {
            if userInTheMiddleOfTyping {
                let textCurrentlyInDisplay = display.text!
                if (digit != decimalSeparator) || !(textCurrentlyInDisplay.contains(decimalSeparator)) {
                    display.text = textCurrentlyInDisplay + digit
                }
            } else {
                display.text = digit
                userInTheMiddleOfTyping = true
            }
        }
    }
    
    var displayValue: Double? {
        get {
            if let text = display.text, let value = Double(text){
                return value
            }
            return nil
        }
        set {
            if let value = newValue {
                display.text = formatter.string(from: NSNumber(value:value))
            }
        }
    }
    
    var displayResult: (result: Double?, isPending: Bool,
                       description: String, error: String?) = (nil, false," ", nil){
        
        // Наблюдатель Свойства модифицирует три IBOutlet метки
        didSet {
            switch displayResult {
                case (nil, _, " ", nil) : displayValue = 0
                case (let result, _,_,nil): displayValue = result
                case (_, _,_,let error): display.text = error!
            }
            
            history.text = displayResult.description != " " ?
                    displayResult.description + (displayResult.isPending ? " …" : " =") : " "
        //    print ("description = NN\(displayResult.description)NN")
            displayM.text = variableValues != nil ? formatter.string(from: NSNumber(value:variableValues!["M"] ?? 0)) : ""
        }
    }
    
    // MARK: - Model
    
    private var brain = CalculatorBrain ()
    private var variableValues : [String: Double]?
    
    @IBAction func performOPeration(_ sender: UIButton) {
        if userInTheMiddleOfTyping {
            if let value = displayValue{
                brain.setOperand(value)
            }
            userInTheMiddleOfTyping = false
        }
        if  let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayResult = brain.evaluate(using: variableValues)
    }
    
    @IBAction func setM(_ sender: UIButton) {
        userInTheMiddleOfTyping = false
        guard let value = displayValue else {return}
        let symbol = String((sender.currentTitle!).characters.dropFirst())
        if variableValues == nil {
            variableValues = [symbol:value]}
        else {
            variableValues![symbol] = value
        }
        displayResult = brain.evaluate(using: variableValues)
    }
    
    @IBAction func pushM(_ sender: UIButton) {
        brain.setOperand(variable: sender.currentTitle!)
        displayResult = brain.evaluate(using: variableValues)
    }
    
    @IBAction func clearAll(_ sender: UIButton) {
        userInTheMiddleOfTyping = false
        brain.clear()
        variableValues = nil
        displayResult = brain.evaluate()
    }
    
    @IBAction func backspace(_ sender: UIButton) {
        if userInTheMiddleOfTyping {
            guard !display.text!.isEmpty else { return }
            display.text = String (display.text!.characters.dropLast())
            if display.text!.isEmpty{
                userInTheMiddleOfTyping = false
                displayResult = brain.evaluate(using: variableValues)
            }
        } else {
            brain.undo()
            displayResult = brain.evaluate(using: variableValues)
            
        }
    }
    
    @IBAction func setDegrees(_ sender: UIButton) {
        brain.isRadian = !brain.isRadian
        radians.setTitle(brain.isRadian ? "radians" : "degrees", for: .normal)
        displayResult = brain.evaluate(using: variableValues)
    }
    
    
}
