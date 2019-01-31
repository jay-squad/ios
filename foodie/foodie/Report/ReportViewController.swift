//
//  ReportViewController.swift
//  foodie
//
//  Created by Austin Du on 2019-01-31.
//  Copyright © 2019 JAY. All rights reserved.
//

import UIKit

class ReportViewController: UIViewController {

    let tableView = UITableView()
    
    var leftNavBtn: UIBarButtonItem?
    var rightNavBtn: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupNavigation()
        setupNibs()
        buildComponents()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
    }
    
    private func setupNibs() {
        
    }
    
    private func buildComponents() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    private func setupNavigation() {
        self.setDefaultNavigationBarStyle()
        
        navigationItem.title = "Profile"
        
        leftNavBtn = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(onCancelButtonTapped(_:)))
        rightNavBtn = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(onSendButtonTapped(_:)))
        navigationItem.rightBarButtonItem = rightNavBtn
    }
    
    @objc private func onCancelButtonTapped(_ sender: UIBarButtonItem?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func onSendButtonTapped(_ sender: UIBarButtonItem?) {
        // TODO: send call
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension ReportViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}
