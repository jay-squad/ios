//
//  RestaurantDetailViewController.swift
//  foodie
//
//  Created by Austin Du on 2018-05-31.
//  Copyright © 2018 JAY. All rights reserved.
//

import UIKit
import CoreLocation

let RestaurantDetailTableViewCellId = "RestaurantDetailTableViewCellId"

class RestaurantDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var restaurant: Restaurant?
    private var menu: Menu?
    
    private func setupNibs() {
        tableView.register(UINib(nibName: "RestaurantDetailTableViewCell", bundle: nil), forCellReuseIdentifier: RestaurantDetailTableViewCellId)
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
                                     medals: [RestaurantMedal(type: .highRating, description: "86% of customers enjoyed their dish")],
                                     website: "www.seoulsoulkoreanrestaurant.ca",
                                     phoneNum: 6506953997)
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
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: RestaurantDetailTableViewCellId, for: indexPath) as? RestaurantDetailTableViewCell {
            cell.configureCell(restaurant: restaurant)
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
