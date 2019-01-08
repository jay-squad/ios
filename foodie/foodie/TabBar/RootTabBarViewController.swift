//
//  RootTabBarViewController.swift
//  foodie
//
//  Created by Austin Du on 2018-06-27.
//  Copyright © 2018 JAY. All rights reserved.
//

import UIKit
import DKImagePickerController

class RootTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = UIColor.cc45DarkGrey
        delegate = self
        for tabBarItem in tabBar.items! {
            tabBarItem.title = nil
            tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }
        tabBar.isHidden = true
    }
    
}

extension RootTabBarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController) -> Bool {
        
        if let navigationController = viewController as? UploadNavigationController,
            let uploadVC = navigationController.viewControllers.first as? UploadViewController {
            
            if uploadVC.uploadImage == nil {
                let pickerController = DKImagePickerController()
                pickerController.setDefaultControllerProperties()
                pickerController.didSelectAssets = { (assets: [DKAsset]) in
                    for asset in assets {
                        asset.fetchOriginalImage(true, completeBlock: { image, _ in
                            if let img = image {
                                uploadVC.uploadImage = img
                            }
                        })
                    }
                }
                self.present(pickerController, animated: true) {}
            }
            return true
        }
        
        return true
    }
}
