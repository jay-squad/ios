//
//  SkillTestingQuestion.swift
//  foodie
//
//  Created by Austin Du on 2019-03-22.
//  Copyright © 2019 JAY. All rights reserved.
//

import Foundation

class SkillTestingQuestion {
    static func generate() -> (String, Int) {
        let x = MathExpression.random()
        let y = MathExpression.random()
        let z = MathExpression(lhs: .Expression(expression: x), rhs: .Expression(expression: y), operator: .plus)
        return (z.description, z.result as! Int)
    }
}


enum MathElement : CustomStringConvertible {
    case Integer(value: Int)
    case Percentage(value: Int)
    case Expression(expression: MathExpression)
    
    var description: String {
        switch self {
        case .Integer(let value): return "\(value)"
        case .Percentage(let percentage): return "\(percentage)%"
        case .Expression(let expr): return expr.description
        }
    }
    
    var nsExpressionFormatString : String {
        switch self {
        case .Integer(let value): return "\(value).0"
        case .Percentage(let percentage): return "\(Double(percentage) / 100)"
        case .Expression(let expr): return "(\(expr.description))"
        }
    }
}

enum MathOperator : String {
    case plus = "+"
    case minus = "-"
    case multiply = "*"
    case divide = "/"
    
    static func random() -> MathOperator {
        let allMathOperators: [MathOperator] = [.plus, .minus, .multiply]
        let index = Int(arc4random_uniform(UInt32(allMathOperators.count)))
        
        return allMathOperators[index]
    }
}

class MathExpression : CustomStringConvertible {
    var lhs: MathElement
    var rhs: MathElement
    var `operator`: MathOperator
    
    init(lhs: MathElement, rhs: MathElement, operator: MathOperator) {
        self.lhs = lhs
        self.rhs = rhs
        self.operator = `operator`
    }
    
    var description: String {
        var leftString = ""
        var rightString = ""
        
        if case .Expression(_) = lhs {
            leftString = "(\(lhs))"
        } else {
            leftString = lhs.description
        }
        if case .Expression(_) = rhs {
            rightString = "(\(rhs))"
        } else {
            rightString = rhs.description
        }
        
        return "\(leftString) \(self.operator.rawValue) \(rightString)"
    }
    
    var result : Any? {
        let format = "\(lhs.nsExpressionFormatString) \(`operator`.rawValue) \(rhs.nsExpressionFormatString)"
        let expr = NSExpression(format: format)
        return expr.expressionValue(with: nil, context: nil)
    }
    
    static func random() -> MathExpression {
        let lhs = MathElement.Integer(value: Int(arc4random_uniform(10)))
        let rhs = MathElement.Integer(value: Int(arc4random_uniform(10)))
        
        return MathExpression(lhs: lhs, rhs: rhs, operator: .random())
    }
}
