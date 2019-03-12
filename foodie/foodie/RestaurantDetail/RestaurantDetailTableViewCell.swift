//
//  RestaurantDetailTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2018-05-31.
//  Copyright © 2018 JAY. All rights reserved.
//

import UIKit
import MapKit

protocol RestaurantDetailTableViewCellDelegate: class {
    func onMoreButtonTapped()
}

class RestaurantDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var externalContainerView: UIView!
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var informationStackView: UIStackView!
    @IBOutlet weak var restaurantNameLabel: UILabel!
    @IBOutlet weak var restaurantCuisineLabel: UILabel!
    @IBOutlet weak var restaurantPriceLabel: UILabel!
    @IBOutlet weak var restaurantDescriptionLabel: UILabel!
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var restaurantWebsiteButton: UIButton!
    @IBOutlet weak var restaurantCallButton: UIButton!
    @IBOutlet weak var restaurantMedalsStackView: UIStackView!
    let restaurantMoreButton = UIButton()
    
    private var restaurant: Restaurant?
    weak var delegate: RestaurantDetailTableViewCellDelegate?
    
    var mapView = MKMapView()

    override func awakeFromNib() {
        super.awakeFromNib()

        externalContainerView.layer.shadowColor = UIColor(red: 200/255.0,
                                                               green: 200/255.0,
                                                               blue: 200/255.0,
                                                               alpha: 1.0).cgColor
        externalContainerView.layer.shadowOffset = CGSize(width: 0, height: 8)
        externalContainerView.layer.shadowRadius = 8
        externalContainerView.layer.shadowOpacity = 0.25

        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(restaurant: Restaurant) {
        self.restaurant = restaurant
        
        restaurantNameLabel.text = restaurant.name
        restaurantCuisineLabel.text = restaurant.cuisine.joined(separator: ", ")
        if restaurant.priceRange.count == 2 {
            restaurantPriceLabel.text = "$\(restaurant.priceRange[0]) - $\(restaurant.priceRange[1])"
        }
        restaurantDescriptionLabel.text = restaurant.description
        
        if restaurantMedalsStackView.arrangedSubviews.count == 0 {
            for medal in restaurant.medals {
                let medalView = RestaurantDetailMedalView(medal: medal)
                restaurantMedalsStackView.addArrangedSubview(medalView)
            }
        }
        
        let annotation = MKPointAnnotation()
        let centerCoordinate = restaurant.location
        annotation.coordinate = centerCoordinate
        mapView.addAnnotation(annotation)
        
        mapView.setRegion(MKCoordinateRegion(center: restaurant.location,
                                             span: MKCoordinateSpan(latitudeDelta: 0.0075, longitudeDelta: 0.0075)),
                          animated: false)

        mapView.setCenter(restaurant.location, animated: false)
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onMapViewTapped)))
        mapView.showsUserLocation = true
        
        if restaurant.website != "" {
            restaurantWebsiteButton.addTarget(self,
                                              action: #selector(onRestaurantWebsiteButtonTapped(_:)),
                                              for: .touchUpInside)
        } else if restaurantWebsiteButton != nil {
            restaurantWebsiteButton.removeFromSuperview()
        }
        
        if restaurant.phoneNum != "" {
            restaurantCallButton.addTarget(self,
                                           action: #selector(onRestaurantCallButtonTapped(_:)),
                                           for: .touchUpInside)
        } else if restaurantCallButton != nil {
            restaurantCallButton.removeFromSuperview()
        }
        
        buildComponents()
    }
    
    private func buildComponents() {
        restaurantMedalsStackView.isHidden = true
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.mapType = .standard
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        
        mapContainerView.addSubview(mapView)
        mapContainerView.applyAutoLayoutInsetsForAllMargins(to: mapView, with: .zero)
        
        restaurantMoreButton.translatesAutoresizingMaskIntoConstraints = false
        restaurantMoreButton.setImage(UIImage(named: "btn_more_yellow"), for: .normal)
        restaurantMoreButton.heightAnchor.constraint(equalToConstant: 30)
        restaurantMoreButton.widthAnchor.constraint(equalToConstant: 30)
        restaurantMoreButton.contentMode = .scaleAspectFit
        restaurantMoreButton.addTarget(self, action: #selector(onRestaurantMoreButtonTapped(_:)), for: .touchUpInside)
        buttonsStackView.addArrangedSubview(restaurantMoreButton)
    }
    
    @objc private func onMapViewTapped() {
        guard let restaurant = restaurant else { return }
        let coordinate = restaurant.location
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary: nil))
        mapItem.name = restaurant.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    @objc private func onRestaurantWebsiteButtonTapped(_ sender: UIButton!) {
        if let website = restaurant?.website, let url = URL(string: website) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func onRestaurantCallButtonTapped(_ sender: UIButton!) {
        if let phoneNumber = restaurant?.phoneNum, let phoneCallURL = URL(string: "tel://\(phoneNumber.digits)") {
            if UIApplication.shared.canOpenURL(phoneCallURL) {
                UIApplication.shared.open(phoneCallURL)
            }
        }
    }
    
    @objc private func onRestaurantMoreButtonTapped(_ sender: UIButton!) {
        delegate?.onMoreButtonTapped()
    }
    
}
