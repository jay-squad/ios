//
//  DishDetailViewController.swift
//  foodie
//
//  Created by Austin Du on 2019-03-06.
//  Copyright © 2019 JAY. All rights reserved.
//

import UIKit
import Crashlytics

class DishDetailViewController: UIViewController {

    let kDishMetadataTableViewCellId = "DishMetadataTableViewCellId"
    
    let tableView = UITableView()
    var dish: Dish?
    var restaurant: Restaurant?
    
    init(dish: Dish, restaurant: Restaurant) {
        self.dish = dish
        self.restaurant = restaurant
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildComponents()
        setupNibs()
        setupTableView()
        setupNavigation()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func buildComponents() {
        view.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.applyAutoLayoutInsetsForAllMargins(to: view.safeAreaLayoutGuide, with: .zero)
    }
    
    private func setupNibs() {
        tableView.register(RestaurantDetailMenuExpandedTableViewCell.self,
                           forCellReuseIdentifier: kRestaurantDetailMenuExpandedTableViewCellId)
        tableView.register(DishMetadataTableViewCell.self,
                           forCellReuseIdentifier: kDishMetadataTableViewCellId)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    private func setupNavigation() {
        navigationItem.title = restaurant?.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "btn_more"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(onMoreButtonTapped))
    }
    
    @objc private func onMoreButtonTapped() {
        if let restaurantId = restaurant?.id, let dishId = dish?.dishId {
            UpdateRequestViewController.presentActionSheet(.dish, sender: self, id: "\(restaurantId),\(dishId)")
        }
    }
    
    public static func push(_ navigationController: UINavigationController?, _ dish: Dish?, _ restaurant: Restaurant?) {
        if let dish = dish, let restaurant = restaurant {
            let vc = DishDetailViewController(dish: dish, restaurant: restaurant)
            navigationController?.pushViewController(vc, animated: true)
        }
    }

}

extension DishDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            if let cell = tableView.dequeueReusableCell(withIdentifier: kRestaurantDetailMenuExpandedTableViewCellId) as? RestaurantDetailMenuExpandedTableViewCell {
                cell.configureCell(dish: dish)
                return cell
            }
        case 1:
            if let cell = tableView.dequeueReusableCell(withIdentifier: kDishMetadataTableViewCellId) as? DishMetadataTableViewCell {
                cell.configureCell(dish)
                cell.delegate = self
                return cell
            }
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
}

extension DishDetailViewController: DishMetadataTableViewCellDelegate {
    func onRestaurantTapped(restaurant: Restaurant) {
        Answers.logContentView(withName: "DishDetail-RestaurantDetail", contentType: "restaurant", contentId: "\(restaurant.id)", customAttributes: nil)
        RestaurantDetailViewController.push(self.navigationController, restaurant)
    }
}
