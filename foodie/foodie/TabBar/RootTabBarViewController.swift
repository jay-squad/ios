//
//  RootTabBarViewController.swift
//  foodie
//
//  Created by Austin Du on 2018-06-27.
//  Copyright © 2018 JAY. All rights reserved.
//

import UIKit
import DKImagePickerController
import Photos.PHImageManager
import FBSDKCoreKit
import NotificationBannerSwift
import Crashlytics

class RootTabBarViewController: UITabBarController {
    lazy var pickerController = DKImagePickerController()
    lazy var uploadVC = UploadViewController()
    
    static var uploadFormHasDraft = false

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = UIColor.cc45DarkGrey
        delegate = self
        viewControllers?.remove(at: 1)

        let dummyVC = UIViewController()
        dummyVC.tabBarItem = UITabBarItem(title: nil,
                                     image: UIImage(named: "btn_upload")!.withRenderingMode(.automatic),
                                     selectedImage: UIImage(named: "btn_upload")!.withRenderingMode(.automatic))
        viewControllers?.insert(dummyVC, at: 1)
        
        for tabBarItem in tabBar.items! {
            tabBarItem.title = nil
            tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }
        
    }
    
}

extension RootTabBarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController) -> Bool {
        
        if viewController == tabBarController.viewControllers?[1] {
            guard FBSDKAccessToken.currentAccessTokenIsActive() else {
                let banner = NotificationBanner(title: nil, subtitle: "You must be logged in to upload content", style: .info)
                banner.haptic = .none
                banner.subtitleLabel?.textAlignment = .center
                banner.show()
                if let vcs = viewControllers {
                    selectedViewController = vcs[vcs.count-1]
                }
                return false
            }
            
            Answers.logContentView(withName: "TabBar-SubmissionInitiate", contentType: "submission", contentId: nil, customAttributes: nil)
            
            pickerController.setDefaultControllerProperties()
            pickerController.inline = true
            pickerController.showsCancelButton = true
            pickerController.UIDelegate = FoodieDKImagePickerControllerUIDelegate()
            pickerController.didSelectAssets = { (assets: [DKAsset]) in
                for asset in assets {
                    let options = PHImageRequestOptions()
                    options.isSynchronous = true
                    asset.fetchOriginalImage(options: options, completeBlock: { image, _ in
                        if let img = image {
                            RootTabBarViewController.uploadFormHasDraft = true
                            self.showDraftBadge()
                            self.uploadVC.delegate = self
                            let leftNavBtn = UIBarButtonItem(title: "Dismiss",
                                                             style: .plain,
                                                             target: self,
                                                             action: #selector(self.onDismissTapped(_:)))
                            self.uploadVC.navigationItem.leftBarButtonItem = leftNavBtn
                            self.uploadVC.uploadImage = img
                            self.uploadVC.willHandlePhotoPickerWithDelegate = true
                            self.pickerController.pushViewController(self.uploadVC, animated: true)
                        }
                    })
                }
            }
            self.present(pickerController, animated: true, completion: {
                self.pickerController.setNavigationBarHidden(false, animated: true)
            })
            return false
        }
        
        return true
    }
    
    @objc fileprivate func onDismissTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
        RootTabBarViewController.showDraftBannerIfNeeded()
    }
    
    static fileprivate func showDraftBannerIfNeeded() {
        if RootTabBarViewController.uploadFormHasDraft {
            let banner = NotificationBanner(title: nil, subtitle: "A draft is temporarily saved.", style: .info)
            banner.haptic = .none
            banner.subtitleLabel?.textAlignment = .center
            banner.show()
        }
    }
    
    private func showDraftBadge() {
        if let tabBarItem = tabBar.items?[1], tabBarItem.badgeValue == nil {
            tabBarItem.badgeValue = "draft"//"●"
//            tabBarItem.badgeColor = .clear
//            tabBarItem.setBadgeTextAttributes([.foregroundColor: UIColor.red], for: .normal)
        }
    }
    
    private func hideDraftBadge() {
        if let tabBarItem = tabBar.items?[1] {
            tabBarItem.badgeValue = nil
        }
    }
}

extension RootTabBarViewController: UploadViewControllerDelegate {
    func onSuccessfulUpload(_ sender: UploadViewController) {
        sender.dismiss(animated: true, completion: nil)
        uploadVC = UploadViewController()
        pickerController = DKImagePickerController()
        RootTabBarViewController.uploadFormHasDraft = false
        hideDraftBadge()
    }
    
    func onChangePhotoRequested(_ sender: UploadViewController) {
        sender.navigationController?.popViewController(animated: true)
    }
}

class FoodieDKImagePickerControllerUIDelegate: DKImagePickerControllerBaseUIDelegate {
    open override func prepareLayout(_ imagePickerController: DKImagePickerController, vc: UIViewController) {
        // do nothing
    }
    
    open override func imagePickerController(_ imagePickerController: DKImagePickerController,
                                             showsCancelButtonForVC vc: UIViewController) {
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Dismiss", style: .plain,
                                                              target: self,
                                                              action: #selector(self.onDismissTapped(_:)))
    }
    
    @objc private func onDismissTapped(_ sender: UIBarButtonItem) {
        imagePickerController.dismiss()
        RootTabBarViewController.showDraftBannerIfNeeded()
    }
}
