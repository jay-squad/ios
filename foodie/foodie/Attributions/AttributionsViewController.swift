//
//  AttributionsViewController.swift
//  foodie
//
//  Created by Austin Du on 2019-03-13.
//  Copyright © 2019 JAY. All rights reserved.
//

import UIKit
import ActiveLabel

class AttributionsViewController: UIViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
        buildComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildComponents()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildComponents()
        setupNavigation()
    }
    
    func setupNavigation() {
        let leftNavBtn = UIBarButtonItem(title: "Dismiss",
                                         style: .plain,
                                         target: self,
                                         action: #selector(onDismissButtonTapped(_:)))
        navigationItem.leftBarButtonItem = leftNavBtn
    }
    
    @objc private func onDismissButtonTapped(_ sender: UIBarButtonItem?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func buildComponents() {
        view.backgroundColor = .white
        let label = ActiveLabel()
        let freepikType = ActiveType.custom(pattern: "\\swww.freepik.com\\b")
        label.enabledTypes = [freepikType]
        label.text = "All food related vector imagery in the app as well as the app icon are Designed by Freepik or macrovector - www.freepik.com"
        label.customColor[freepikType] = UIColor.ccOchre
        label.customSelectedColor[freepikType] = UIColor.ccOchre
        label.numberOfLines = 0
        label.textAlignment = .center
        label.handleCustomTap(for: freepikType) { _ in
            if let link = URL(string: "https://www.freepik.com") {
                UIApplication.shared.open(link)
            }
        }
        label.font = label.font.withSize(14)
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.applyAutoLayoutInsetsForAllMargins(to: view.safeAreaLayoutGuide, with: UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10))
    }
    
}
