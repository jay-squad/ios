//
//  FacebookButton.swift
//  foodie
//
//  Created by Austin Du on 2019-02-19.
//  Copyright © 2019 JAY. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import ActiveLabel

class FacebookButton: FBSDKLoginButton {
    
    let standardButtonHeight: CGFloat = 38.0
    let standardButtonWidth: CGFloat = 200.0
    
    override func updateConstraints() {
        // deactivate height constraints added by the facebook sdk (we'll force our own instrinsic height)
        for contraint in constraints
            where contraint.firstAttribute == .height && contraint.constant < standardButtonHeight {
                // deactivate this constraint
                contraint.isActive = false
        }
        super.updateConstraints()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: standardButtonWidth, height: standardButtonHeight)
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let logoSize: CGFloat = 24.0
        let centerY = contentRect.midY
        let y: CGFloat = centerY - (logoSize / 2.0)
        return CGRect(x: y, y: y, width: logoSize, height: logoSize)
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        if isHidden || bounds.isEmpty {
            return .zero
        }
        
        let imageRect = self.imageRect(forContentRect: contentRect)
        let titleX = imageRect.maxX
        let titleRect = CGRect(x: titleX, y: 0, width: contentRect.width - titleX, height: contentRect.height)
        return titleRect
    }
    
    static func getLegalLabel() -> ActiveLabel {
        let label = ActiveLabel()
        let termsAndConditionsType = ActiveType.custom(pattern: "\\sterms and conditions\\b")
        let privacyPolicyType = ActiveType.custom(pattern: "\\sprivacy policy\\b")
        label.enabledTypes = [termsAndConditionsType, privacyPolicyType]
        label.text = "By signing up to Foodie, you agree to our terms and conditions and our privacy policy"
        label.customColor[termsAndConditionsType] = UIColor.ccOchre
        label.customSelectedColor[termsAndConditionsType] = UIColor.ccOchre
        label.customColor[privacyPolicyType] = UIColor.ccOchre
        label.customSelectedColor[privacyPolicyType] = UIColor.ccOchre
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = label.font.withSize(11.0)
        
        label.handleCustomTap(for: termsAndConditionsType) { element in
            if let link = URL(string: "https://beafoodie.com/termsandconditions.html") {
                UIApplication.shared.open(link)
            }
        }
        
        label.handleCustomTap(for: privacyPolicyType) { element in
            if let link = URL(string: "https://beafoodie.com/privacypolicy.html") {
                UIApplication.shared.open(link)
            }
        }
        
        return label
    }
    
}
