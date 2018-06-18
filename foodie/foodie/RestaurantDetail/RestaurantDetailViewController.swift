//
//  RestaurantDetailViewController.swift
//  foodie
//
//  Created by Austin Du on 2018-05-31.
//  Copyright © 2018 JAY. All rights reserved.
//

import UIKit
import CoreLocation

let kRestaurantDetailTableViewCellId = "RestaurantDetailTableViewCellId"
let kRestaurantDetailDisplayOptionsTableViewCellId = "RestaurantDetailDisplayOptionsTableViewCellId"

class RestaurantDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var restaurant: Restaurant?
    private var menu: Menu?

    private func setupNibs() {
        tableView.register(UINib(nibName: "RestaurantDetailTableViewCell", bundle: nil),
                           forCellReuseIdentifier: kRestaurantDetailTableViewCellId)
        tableView.register(RestaurantDetailDisplayOptionsTableViewCell.self,
                           forCellReuseIdentifier: kRestaurantDetailDisplayOptionsTableViewCellId)
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }

    private func setupDataSource() {
        self.restaurant = Restaurant(name: "Seoul Soul",
                                     cuisine: ["Korean, Asian"],
                                     priceRange: [10, 20],
                                     location: CLLocationCoordinate2D(latitude: 43.4752071, longitude: -80.5395287),
                                     description: "Authentic homestyle Korean cuisine, made with care by chef Kim.",
                                     medals: [RestaurantMedal(type: .highRating,
                                                              description: "86% of customers enjoyed their dish")],
                                     website: "www.seoulsoulkoreanrestaurant.ca",
                                     phoneNum: 6506953997)
        self.menu = Menu()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNibs()
        setupTableView()
        setupDataSource()
    }

}

extension RestaurantDetailViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let restaurant = self.restaurant else { return UITableViewCell() }

        switch indexPath.section {
        case 0:
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: kRestaurantDetailTableViewCellId,
                for: indexPath)
                as? RestaurantDetailTableViewCell {
                cell.configureCell(restaurant: restaurant)
                return cell
            }
        case 1:
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: kRestaurantDetailDisplayOptionsTableViewCellId,
                for: indexPath)
                as? RestaurantDetailDisplayOptionsTableViewCell {
                cell.delegate = self
                return cell
            }
        case 2:
            if let menu = menu {
                switch menu.displayOption {
                case .grid:
                    
                }
            }
            
        default:
            break
        }
        return UITableViewCell()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

}

extension RestaurantDetailViewController: RestaurantDetailDisplayOptionsTableViewCellDelegate {
    func onDisplayOptionChanged(type: RestaurantDetailDisplayOption) {
        switch type {
        case .grid:
            menu?.displayOption = .grid
        case .list:
            menu?.displayOption = .list
        case.expanded:
            menu?.displayOption = .expanded
        }
    }
}
