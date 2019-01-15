//
//  ProfileViewController.swift
//  foodie
//
//  Created by Austin Du on 2019-01-08.
//  Copyright © 2019 JAY. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    let tableView = UITableView()
    let kProfileSummaryTableViewCellId = "ProfileSummaryTableViewCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadProfile()
        setupTableView()
        setupNavigation()
        setupNibs()
        buildComponents()
    }
    
    private func loadProfile() {
        
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
    }
    
    private func setupNavigation() {
        self.setDefaultNavigationBarStyle()
        
        navigationItem.title = "Profile"
        
//        let rightNavBtn = UIBarButtonItem(title: "stuff",
//                                          style: .plain,
//                                          target: self,
//                                          action: #selector(onSubmitButtonTapped(_:)))
//        navigationItem.rightBarButtonItem = rightNavBtn
    }
    
    private func setupNibs() {
        tableView.register(ProfileSummaryTableViewCell.self,
                           forCellReuseIdentifier: kProfileSummaryTableViewCellId)
    }
    
    private func buildComponents() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }

}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: kProfileSummaryTableViewCellId,
                                                    for: indexPath) as? ProfileSummaryTableViewCell {
//            cell.configureCell
            return cell
        }
        
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}
