//
//  UUIViewController.swift
//  foodie
//
//  Created by Austin Du on 2018-06-28.
//  Copyright © 2018 JAY. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setDefaultNavigationBarStyle() {
        navigationController?.navigationBar.barTintColor = UIColor.cc253UltraLightGrey
        navigationController?.navigationBar.tintColor = UIColor.cc45DarkGrey
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: UIFont(font: .helveticaNeueBold, size: 18.0)!,
             NSAttributedString.Key.foregroundColor: UIColor.cc45DarkGrey]
    }
}
