//
//  UpdateRequestViewController.swift
//  foodie
//
//  Created by Austin Du on 2019-01-31.
//  Copyright © 2019 JAY. All rights reserved.
//

import UIKit

class UpdateRequestViewController: UIViewController {

    let kUpdateRequestTableViewCellId = "UpdateRequestTableViewCellId"
    
    enum UpdateSource {
        case dish
        case section
        case restaurant
    }
    
    enum UpdateRequestType {
        case dishReport
        case sectionReport
        case restaurantReport
        case dishAmend
        case sectionAmend
        case restaurantAmend
        case error
        
        var title: String {
            switch self {
            case .dishReport:
                return "Report a Dish"
            case .dishAmend:
                return "Amend a Dish"
            case .sectionReport:
                return "Report a Menu Section"
            case .sectionAmend:
                return "Amend a Menu Section"
            case .restaurantReport:
                return "Report a Restaurant"
            case .restaurantAmend:
                return "Amend a Restaurant"
            case .error:
                return ""
            }
        }
        
        var reasons: [String] {
            switch self {
            case .dishReport:
                return ["The image contains offensive material",
                        "The name contains offensive text",
                        "The description contains offensive text",
                        "The dish does not exist",
                        "The image does not match the dish",
                        "The description is misleading"]
            case .dishAmend:
                return ["The dish name contains a typo",
                        "The dish is in the wrong section",
                        "The description contains a typo",
                        "The description could be better",
                        "The price is wrong"]
            case .sectionReport:
                return ["The section name contains offensive text",
                        "The section name does not exist"]
            case .sectionAmend:
                return ["The section name contains a typo"]
            case .restaurantAmend:
                return [
                        "The restaurant name contains a typo",
                        "The restaurant description contains a typo",
                        "The restaurant description could be better",
                        "The restaurant cuisine type is wrong",
                        "The restaurant phone number is wrong",
                        "The restaurant website is wrong",
                        "The restaurant location is wrong"]
            case .restaurantReport:
                return ["The restaurant name contains offensive text",
                        "The restaurant description contains offensive text",
                        "The restaurant cuisine contains offensive text",
                        "The restaurant does not exist",
                        "The restaurant description is misleading"]
            case .error:
                return []
            }
        }
    }
    
    let tableView = UITableView()
    
    var leftNavBtn: UIBarButtonItem?
    var rightNavBtn: UIBarButtonItem?
    
    var dataSource: UpdateRequestType
    var selectedIndexPath: IndexPath?
    
    init(_ type: UpdateRequestType) {
        dataSource = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        dataSource = .error
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupNavigation()
        setupNibs()
        buildComponents()
        hideKeyboardWhenTappedAround()
        shiftViewWhenKeyboardAppears()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
    }
    
    private func setupNibs() {
        tableView.register(UpdateRequestTableViewCell.self,
                           forCellReuseIdentifier: kUpdateRequestTableViewCellId)
        tableView.register(AdditionalInfoTableViewCell.self,
                           forCellReuseIdentifier: kAdditionalInfoTableViewCellId)
        tableView.register(SpacerTableViewCell.self, forCellReuseIdentifier: kSpacerTableViewCellId)
    }
    
    private func buildComponents() {
        view.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.applyAutoLayoutInsetsForAllMargins(to: view.safeAreaLayoutGuide, with: .zero)

    }
    
    private func setupNavigation() {
        self.setDefaultNavigationBarStyle()
        
        navigationItem.title = dataSource.title
        
        leftNavBtn = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(onCancelButtonTapped(_:)))
        rightNavBtn = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(onSendButtonTapped(_:)))
        navigationItem.leftBarButtonItem = leftNavBtn
        navigationItem.rightBarButtonItem = rightNavBtn
    }
    
    @objc private func onCancelButtonTapped(_ sender: UIBarButtonItem?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func onSendButtonTapped(_ sender: UIBarButtonItem?) {
        if let row = selectedIndexPath?.row {
            let reason = dataSource.reasons[row]
            let description: String?
            if let cell = tableView.cellForRow(at: IndexPath(row: tableView.numberOfRows(inSection: 0)-1, section: 0))
                as? AdditionalInfoTableViewCell,
                let desc = cell.additionalNotesTextField.text {
                description = desc
            }
            
            // SEND ACTION HERE
            
            self.dismiss(animated: true, completion: nil)
        }
        
        // TODO: ux feedback when no reason is selected
    }
    
    public static func presentActionSheet(_ source: UpdateSource, sender: UIViewController) {
        let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let amend = UIAlertAction(title: "Amend this dish", style: .default) { _ in
            var vc: UpdateRequestViewController
            switch source {
            case .dish:
                vc = UpdateRequestViewController(.dishAmend)
            case .restaurant:
                vc = UpdateRequestViewController(.restaurantAmend)
            case .section:
                vc = UpdateRequestViewController(.sectionAmend)
            }
            presentUpdateRequest(vc)
        }
        let report = UIAlertAction(title: "Report this dish", style: .destructive) { _ in
            var vc: UpdateRequestViewController
            switch source {
            case .dish:
                vc = UpdateRequestViewController(.dishReport)
            case .restaurant:
                vc = UpdateRequestViewController(.restaurantReport)
            case .section:
                vc = UpdateRequestViewController(.sectionReport)
            }
            presentUpdateRequest(vc)
        }
        actionController.addAction(cancel)
        actionController.addAction(amend)
        actionController.addAction(report)
        
        sender.present(actionController, animated: true, completion: nil)
        
        func presentUpdateRequest(_ vc: UpdateRequestViewController) {
            let nc = UINavigationController(rootViewController: vc)
            sender.present(nc, animated: true, completion: nil)
        }
        
    }
    
}

extension UpdateRequestViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1,
            let cell = tableView.dequeueReusableCell(withIdentifier: kAdditionalInfoTableViewCellId) as? AdditionalInfoTableViewCell {
            cell.configureCell(title: "Additional details", subtitle: "Give further details/reasoning if you have any to make the review process smoother", placeholder: "e.g. \"spaghetti\" was spelled wrong")
            return cell
        }
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-2,
            let cell = tableView.dequeueReusableCell(withIdentifier: kSpacerTableViewCellId) as? SpacerTableViewCell {
            cell.configureCell(height: 30)
            return cell
        }
        
//        if indexPath.row == 0,
//            let cell = tableView.dequeueReusableCell(withIdentifier: kSpacerTableViewCellId) as? SpacerTableViewCell {
//            cell.configureCell(height: 5)
//            return cell
//        }
        
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: kUpdateRequestTableViewCellId,
            for: indexPath) as? UpdateRequestTableViewCell {
            cell.configureCell(reason: dataSource.reasons[indexPath.row])
            return cell
        }
        
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedIndexPath = selectedIndexPath {
            tableView.cellForRow(at: selectedIndexPath)?.isSelected = false
        }
        if selectedIndexPath == indexPath {
            selectedIndexPath = nil
        } else {
            selectedIndexPath = indexPath
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.reasons.count + 2
    }
}
