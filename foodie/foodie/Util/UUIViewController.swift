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
        hideKeyboardWhenTapping(view: view)
    }
    
    func hideKeyboardWhenTapping(view: UIView?) {
        if let view = view {
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            tap.cancelsTouchesInView = false
            view.addGestureRecognizer(tap)
        }
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
    
    func shiftViewWhenKeyboardAppears() {
        NotificationCenter.default.addObserver(self, selector: #selector(shiftViewKeyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shiftViewKeyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func disableShiftViewWhenKeyboardAppears() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func shiftViewKeyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                var tabBarHeight: CGFloat = 0
                if let tabBar = tabBarController?.tabBar {
                    tabBarHeight = tabBar.frame.size.height
                }
                self.view.frame.origin.y -= keyboardSize.height - tabBarHeight
            }
        }
    }
    
    @objc func shiftViewKeyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func viewIsShiftedFromKeyboard() -> Bool {
        return self.view.frame.origin.y != 0
    }

}
