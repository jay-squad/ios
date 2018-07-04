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

let kSearchRestaurantTableViewCellId = "SearchRestaurantTableViewCellId"
let kSearchDishTableViewCellId = "SearchDishTableViewCellId"

class SearchViewController: UIViewController {

    let tableView = UITableView()
    let searchStackView = UIStackView()
    let searchTextField = UITextField()
    let searchActionButton = UIButton()
    
    var searchResults: [SearchResult] = []
    let searchResultType: SearchResult.ResultType = .dish
    var dishesTapGestureRecognizer: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNibs()
        setupTableView()
        setupNavigation()
        buildComponents()
        hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide),
                                               name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
        query(with: "asdf")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupNavigation() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Search", style: .plain, target: nil, action: nil)
    }
    
    private func setupNibs() {
        tableView.register(SearchDishTableViewCell.self,
                           forCellReuseIdentifier: kSearchDishTableViewCellId)
        tableView.register(SearchRestaurantTableViewCell.self,
                           forCellReuseIdentifier: kSearchRestaurantTableViewCellId)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        tableView.isUserInteractionEnabled = false
    }
    
    @objc func keyboardDidHide(notification: NSNotification) {
        tableView.isUserInteractionEnabled = true
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    func buildComponents() {

        tableView.translatesAutoresizingMaskIntoConstraints = false
        searchStackView.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchActionButton.translatesAutoresizingMaskIntoConstraints = false
        
        searchStackView.axis = .horizontal
        
        searchTextField.font = UIFont(font: .helveticaNeueMedium, size: 24.0)
        searchTextField.textColor = UIColor.cc74MediumGrey
        searchTextField.borderStyle = .none
        searchTextField.placeholder = "Search"
        
        searchStackView.addArrangedSubview(searchTextField)
        searchStackView.addArrangedSubview(searchActionButton)

        view.addSubview(tableView)
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
        
    }
    
    func query(with query: String?) {
        
        let restaurant = Restaurant(name: "Seoul Soul",
                                     cuisine: ["Korean, Asian"],
                                     priceRange: [10, 20],
                                     location: CLLocationCoordinate2D(latitude: 43.4752071, longitude: -80.5395287),
                                     description: "Authentic homestyle Korean cuisine, made with care by chef Kim.",
                                     medals: [RestaurantMedal(type: .highRating,
                                                              description: "86% of customers enjoyed their dish")],
                                     website: "www.seoulsoulkoreanrestaurant.ca",
                                     phoneNum: 6506953997)
        
        let path = Bundle.main.path(forResource: "testmodel", ofType: "txt")
        var text: String = ""
        do {
            text = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        } catch {
            print("file bad")
        }
        if let data = text.data(using: .utf8, allowLossyConversion: false) {
            do {
                let json = try JSON(data: data)
                let menu = Menu(json: json)
                
                if query != nil {
                    let newSearchResult = SearchResult()
                    newSearchResult.type = .dish
                    
                    // restaurant type
                    newSearchResult.restaurant = restaurant
                    newSearchResult.restaurantImages = [menu.getDish(section: 0, row: 0)?.image,
                    menu.getDish(section: 0, row: 1)?.image,
                    menu.getDish(section: 0, row: 2)?.image,
                    menu.getDish(section: 0, row: 3)?.image,
                    menu.getDish(section: 1, row: 0)?.image,
                    menu.getDish(section: 1, row: 1)?.image]
                    
                    // dish type
                    newSearchResult.dish = menu.getDish(section: 0, row: 0)
                    
                    searchResults.append(newSearchResult)
                    searchResults.append(newSearchResult)
                    
                    tableView.reloadData()
                }
                
            } catch {
                print("json bad")
            }
        }
        
        if searchResultType == .dish {
            dishesTapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                action: #selector(self.handleDishesTap(_:)))
            dishesTapGestureRecognizer?.delegate = self
            self.tableView.addGestureRecognizer(dishesTapGestureRecognizer!)
        } else {
            if dishesTapGestureRecognizer != nil {
                self.tableView.removeGestureRecognizer(dishesTapGestureRecognizer!)
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
                            segueToRestaurantDetailedVC(restaurant: cell.searchResult1!.restaurant)
                        } else if cell.searchResult2 != nil, cell.viewComponent2.frame.contains(pointInCell) {
                            segueToRestaurantDetailedVC(restaurant: cell.searchResult2!.restaurant)
                        }
                    }
                }
            }
        }
    }
    
    private func segueToRestaurantDetailedVC(restaurant: Restaurant?) {
        if let restaurant = restaurant,
            let detailedRestaurantVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(
            withIdentifier: CommonIdentifiers.RestaurantDetailViewControllerId) as? RestaurantDetailViewController {
            detailedRestaurantVC.restaurant = restaurant
            self.navigationController?.pushViewController(detailedRestaurantVC, animated: true)
        }
    }
    
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        switch searchResultType {
        case .restaurant:
            return searchResults.count
        case .dish:
            return searchResults.count/2
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        segueToRestaurantDetailedVC(restaurant: searchResults[indexPath.row].restaurant)
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
