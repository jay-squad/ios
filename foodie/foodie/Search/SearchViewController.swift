//
//  SearchViewController.swift
//  foodie
//
//  Created by Austin Du on 2018-07-04.
//  Copyright © 2018 JAY. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON
import SwiftyUserDefaults
import Crashlytics
import GradientLoadingBar

extension DefaultsKeys {
    static let launchCount = DefaultsKey<Int>("user_launch_count")
}

let kSearchRestaurantTableViewCellId = "SearchRestaurantTableViewCellId"
let kSearchDishTableViewCellId = "SearchDishTableViewCellId"
let kPaginationPendingTableViewCellId = "kPaginationPendingTableViewCellId"

class SearchViewController: UIViewController {

    let tableView = UITableView()
    let searchStackView = UIStackView()
    let searchTextField = UITextField()
    let searchActionButton = UIButton()
    let searchTypeToggleButton = UIButton()
    let searchByDishText = "Searching by dish"
    let searchByRestaurantText = "Searching by restaurant"
    
    var searchResults: [SearchResult] = []
    var searchResultType: SearchResult.ResultType = .restaurant
    var nextSearchResultType: SearchResult.ResultType = .restaurant
    var dishesTapGestureRecognizer: UITapGestureRecognizer?
    
    var isFirstLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        onboardingIfNeeded()
        
        setupNibs()
        setupTableView()
        setupNavigation()
        buildComponents()
        hideKeyboardWhenTapping(view: tableView)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide),
                                               name: UIResponder.keyboardDidHideNotification, object: nil)
        searchActionButton.addTarget(self,
                                     action: #selector(onSearchActionButtonTapped(_:)),
                                     for: .touchUpInside)
        searchTypeToggleButton.addTarget(self,
                                         action: #selector(onSearchTypeToggleButtonTapped(_:)),
                                         for: .touchUpInside)
        query(with: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func onboardingIfNeeded() {
        if Defaults[.launchCount] == 0 {
            Defaults[.launchCount] += 1
            let onboardingVC = OnboardingViewController()
            self.present(onboardingVC, animated: true, completion: nil)
        }
    }
    
    private func setupNavigation() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Search", style: .plain, target: nil, action: nil)
    }
    
    private func setupNibs() {
        tableView.register(SearchDishTableViewCell.self,
                           forCellReuseIdentifier: kSearchDishTableViewCellId)
        tableView.register(SearchRestaurantTableViewCell.self,
                           forCellReuseIdentifier: kSearchRestaurantTableViewCellId)
        tableView.register(PaginationPendingTableViewCell.self,
                           forCellReuseIdentifier: kPaginationPendingTableViewCellId)
        tableView.register(FoodieEmptyStateTableViewCell.self,
                           forCellReuseIdentifier: kFoodieEmptyStateTableViewCellId)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        searchActionButton.setImage(UIImage(named: "btn_close"), for: .normal)
        self.searchTypeToggleButton.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.2) {
            self.searchTypeToggleButton.alpha = 1.0
            self.searchTypeToggleButton.frame.origin.y = 70.0
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.searchTypeToggleButton.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.2) {
            self.searchTypeToggleButton.alpha = 0.0
            self.searchTypeToggleButton.frame.origin.y = 0.0
        }
    }
    
    @objc func keyboardDidHide(notification: NSNotification) {
        if searchTextField.text == nil || searchTextField.text == "" {
            searchActionButton.setImage(UIImage(named: "btn_search"), for: .normal)
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
    }
    
    @objc func onSearchActionButtonTapped(_ sender: UIButton!) {
        if searchActionButton.currentImage == UIImage(named: "btn_close") {
            searchTextField.text = nil
            searchActionButton.setImage(UIImage(named: "btn_search"), for: .normal)
        } else {
            searchTextField.becomeFirstResponder()
        }
    }
    
    @objc func onSearchTypeToggleButtonTapped(_ sender: UIButton!) {
        if sender.currentTitle == searchByRestaurantText {
            sender.setTitle(searchByDishText, for: .normal)
            nextSearchResultType = .dish
        } else if sender.currentTitle == searchByDishText {
            sender.setTitle(searchByRestaurantText, for: .normal)
            nextSearchResultType = .restaurant
        }
    }
    
    func buildComponents() {

        tableView.translatesAutoresizingMaskIntoConstraints = false
        searchStackView.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchActionButton.translatesAutoresizingMaskIntoConstraints = false
        
        searchStackView.axis = .horizontal
        searchStackView.backgroundColor = .white
        
        searchActionButton.setImage(UIImage(named: "btn_search"), for: .normal)
        
        searchTextField.font = UIFont(font: .helveticaNeueMedium, size: 24.0)
        searchTextField.textColor = UIColor.cc74MediumGrey
        searchTextField.borderStyle = .none
        searchTextField.placeholder = "Search"
        searchTextField.delegate = self
        
        searchStackView.addArrangedSubview(searchTextField)
        searchStackView.addArrangedSubview(searchActionButton)

        view.addSubview(tableView)
        view.addSubview(searchTypeToggleButton)
        view.addSubview(searchStackView)
        
        searchActionButton.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
        
        searchStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        searchStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                 constant: 16.0).isActive = true
        searchStackView.heightAnchor.constraint(equalToConstant: 58.0).isActive = true
        searchStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                  constant: -16.0).isActive = true
        searchStackView.bottomAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        searchTypeToggleButton.frame = CGRect(x: UIScreen.main.bounds.width/2 - 90, y: 0, width: 180, height: 30.0)
        searchTypeToggleButton.backgroundColor = .white
        searchTypeToggleButton.layer.cornerRadius = 15.0
        searchTypeToggleButton.applyDefaultShadow()
        searchTypeToggleButton.setTitle(searchByRestaurantText, for: .normal)
        searchTypeToggleButton.setTitleColor(UIColor.ccOchre, for: .normal)
        searchTypeToggleButton.titleLabel?.font = UIFont(font: .helveticaNeue, size: 12.0)
        searchTypeToggleButton.isUserInteractionEnabled = false
        searchTypeToggleButton.isExclusiveTouch = true
        searchTypeToggleButton.alpha = 0.0
        
    }
    
    func query(with query: String?) {
        GradientLoadingBar.shared.show()
        Answers.logSearch(withQuery: query, customAttributes: ["type": nextSearchResultType.rawValue])
        switch nextSearchResultType {
        case .restaurant:
            if dishesTapGestureRecognizer != nil {
                self.tableView.removeGestureRecognizer(dishesTapGestureRecognizer!)
            }
            NetworkManager.shared.searchRestaurant(query: query) { (json, error, code) in
                self.isFirstLoad = false
                GradientLoadingBar.shared.hide()
                if let restaurantJSONs = json?.array {
                    self.searchResults.removeAll()
                    for restaurantJSON in restaurantJSONs {
                        var images: [String?] = []
                        if let minimenu = restaurantJSON["menu"].array {
                            for item in minimenu {
                                if let imageUrl = item[1][0]["item_images"][0]["link"].string {
                                    images.append(imageUrl)
                                }
                            }
                        }
                        self.searchResults.append(SearchResult(restaurant:
                            Restaurant(json: restaurantJSON["restaurant"]), restaurantImages: images))
                    }
                    self.searchResultType = self.nextSearchResultType
                    self.tableView.reloadData()
                } else if let error = error {
                    print("----------- ERROR ---------------")
                    print(error.localizedDescription)
                }
            }
        case .dish:
            dishesTapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                action: #selector(self.handleDishesTap(_:)))
            dishesTapGestureRecognizer?.delegate = self
            self.tableView.addGestureRecognizer(dishesTapGestureRecognizer!)
            NetworkManager.shared.searchDish(query: query) { (json, error, _) in
                self.isFirstLoad = false
                GradientLoadingBar.shared.hide()
                if let dishJSONs = json?.array {
                    self.searchResults.removeAll()
                    for dishJSON in dishJSONs {
                        self.searchResults.append(SearchResult(dish: Dish(json: dishJSON)))
                    }
                    self.searchResultType = self.nextSearchResultType
                    self.tableView.reloadData()
                } else if let error = error {
                    print("----------- ERROR ---------------")
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    @objc private func handleDishesTap(_ gestureRecognizer: UITapGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            if let tableView = gestureRecognizer.view as? UITableView {
                let p = gestureRecognizer.location(in: gestureRecognizer.view)
                if let indexPath = tableView.indexPathForRow(at: p) {
                    if let cell = tableView.cellForRow(at: indexPath) as? SearchDishTableViewCell {
                        let pointInCell = gestureRecognizer.location(in: cell)

                        if cell.searchResult1 != nil, cell.viewComponent1.frame.contains(pointInCell) {
                            if let id = cell.searchResult1!.dish?.dishId {
                                Answers.logContentView(withName: "Search-DishDetail", contentType: "dish", contentId: "\(id)", customAttributes: nil)
                            }
                            DishDetailViewController.push(self.navigationController, cell.searchResult1!.dish, cell.searchResult1?.restaurant)
                        } else if cell.searchResult2 != nil, cell.viewComponent2.frame.contains(pointInCell) {
                            if let id = cell.searchResult2!.dish?.dishId {
                                Answers.logContentView(withName: "Search-DishDetail", contentType: "dish", contentId: "\(id)", customAttributes: nil)
                            }
                            DishDetailViewController.push(self.navigationController, cell.searchResult2!.dish, cell.searchResult2?.restaurant)
                        }
                    }
                }
            }
        }
    }
    
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        if indexPath.section == tableView.numberOfSections-1
//            && indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1 {
//            // TODO: and check that it's not the last page of pagination
//            if let cell = tableView.dequeueReusableCell(withIdentifier: kPaginationPendingTableViewCellId,
//                                                        for: indexPath) as? PaginationPendingTableViewCell {
//                return cell
//            }
//        }
        if searchResults.count == 0 && !isFirstLoad {
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: kFoodieEmptyStateTableViewCellId,
                for: indexPath)
                as? FoodieEmptyStateTableViewCell {
                var titleText = ""
                var imageString = ""
                if searchResultType == .restaurant {
                    titleText = "No results availble from your restaurant search.\nRestaurant submissions are coming soon!"
                    imageString = "dimsum"
                } else {
                    titleText = "No results availble from your dish search."
                    imageString = "takoyaki"
                }
                cell.configureCell(text: titleText,
                                   imageString: imageString)
                return cell
            }
        }
        
        switch searchResultType {
        case .restaurant:
            if let cell = tableView.dequeueReusableCell(withIdentifier: kSearchRestaurantTableViewCellId,
                                                        for: indexPath) as? SearchRestaurantTableViewCell {
                cell.configureCell(searchResult: searchResults[indexPath.row])
                return cell
            }
        case .dish:
            if let cell = tableView.dequeueReusableCell(withIdentifier: kSearchDishTableViewCellId,
                                                        for: indexPath) as? SearchDishTableViewCell {
                cell.configureCell(searchResult1: searchResults[indexPath.row * 2],
                                   searchResult2: (indexPath.row * 2 + 1 < searchResults.count) ?
                                                   searchResults[indexPath.row * 2 + 1] : nil)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchResults.count == 0 && !isFirstLoad { return 1 }
        switch searchResultType {
        case .restaurant:
            return searchResults.count //+ 1
        case .dish:
            return searchResults.count/2 //+ 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < searchResults.count else { return }
        if let id = searchResults[indexPath.row].restaurant?.id {
            Answers.logContentView(withName: "Search-RestaurantDetail", contentType: "restaurant", contentId: "\(id)", customAttributes: nil)
        }
//        if !isLastRow(indexPath: indexPath) {
            RestaurantDetailViewController.push(self.navigationController, searchResults[indexPath.row].restaurant)
//        }
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if isLastRow(indexPath: indexPath) {
//            // TODO: get next page and repopulate
//
//        }
//    }
    
    private func isLastRow(indexPath: IndexPath) -> Bool {
        return indexPath.section == tableView.numberOfSections - 1
            && indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
    }
}

extension SearchViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard searchResultType == .dish else { return false }
        if let tableView = gestureRecognizer.view as? UITableView {
            let p = gestureRecognizer.location(in: gestureRecognizer.view)
            if tableView.indexPathForRow(at: p) != nil {
                return true
            }
        }
        return false
    }
}

extension SearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let queryString = textField.text else { return true }
        query(with: queryString)
        return true
    }

}
