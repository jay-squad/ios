//
//  UploadRestaurantIfNewTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2019-03-19.
//  Copyright © 2019 JAY. All rights reserved.
//

import UIKit
import TextFieldEffects
import Validator
import MapKit

class UploadRestaurantIfNewTableViewCell: FormComponentTableViewCell {

    let kWaterlooPlaza = CLLocationCoordinate2D(latitude: 43.4721862, longitude: -80.5376677)
    
    let descriptionTextfield = HoshiTextField()
    let phoneNumberTextfield = HoshiTextField()
    let websiteTextfield = HoshiTextField()
    let cuisineTypeTextfield = HoshiTextField()
    let mapView = MKMapView()
    
    var restaurantName: String?
    
    var locationManager = CLLocationManager()
    
    var didMapInitiallyRender: Bool = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addValidationRules()
    }
    
    func configureCell(restaurantName: String?) {
        self.restaurantName = restaurantName
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        mapView.showsUserLocation = true
        addMapTrackingButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addValidationRules()
    }
    
    override func buildComponents() {
        super.buildComponents()
        
        setCellHeader(title: "Add a New Restaurant", subtitle: "Optionally fill out additional details about the restaurant.")
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 24.0
       
        let mapViewContainer = UIView()
        let descriptionView = UIView()
        let cuisineTypeView = UIView()
        let phoneNumberView = UIView()
        let websiteView = UIView()
        
        descriptionView.translatesAutoresizingMaskIntoConstraints = false
        cuisineTypeView.translatesAutoresizingMaskIntoConstraints = false
        phoneNumberView.translatesAutoresizingMaskIntoConstraints = false
        websiteView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(mapViewContainer)
        stackView.addArrangedSubview(descriptionView)
        stackView.addArrangedSubview(cuisineTypeView)
        stackView.addArrangedSubview(websiteView)
        stackView.addArrangedSubview(phoneNumberView)
        customViewContainer.addSubview(stackView)
        
        let mapViewLabel = UILabel()
        mapViewLabel.translatesAutoresizingMaskIntoConstraints = false
        mapViewLabel.text = "Is this restaurant's location correct?"
        mapViewLabel.font = UIFont(font: .helveticaNeue, size: 14)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        
        let kMapViewCenterMarkerHeight: CGFloat = 50
        let mapViewCenterMarker = UIImageView()
        mapViewCenterMarker.translatesAutoresizingMaskIntoConstraints = false
        mapViewCenterMarker.image = UIImage(named: "icn_select_location")
        mapViewCenterMarker.contentMode = .scaleAspectFit
        mapViewCenterMarker.isUserInteractionEnabled = false
        mapViewCenterMarker.heightAnchor.constraint(equalToConstant: kMapViewCenterMarkerHeight).isActive = true
        
        mapViewContainer.addSubview(mapView)
        mapViewContainer.addSubview(mapViewLabel)
        mapViewContainer.addSubview(mapViewCenterMarker)
        mapViewContainer.leadingAnchor.constraint(equalTo: mapViewLabel.leadingAnchor).isActive = true
        mapViewContainer.trailingAnchor.constraint(equalTo: mapViewLabel.trailingAnchor).isActive = true
        mapViewContainer.topAnchor.constraint(equalTo: mapViewLabel.topAnchor).isActive = true
        mapViewLabel.bottomAnchor.constraint(equalTo: mapView.topAnchor, constant: -10).isActive = true
        mapViewCenterMarker.centerXAnchor.constraint(equalTo: mapView.centerXAnchor).isActive = true
        mapViewCenterMarker.centerYAnchor.constraint(equalTo: mapView.centerYAnchor, constant: -kMapViewCenterMarkerHeight/2).isActive = true
        
        mapViewContainer.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: kStackViewPadding).isActive = true
        mapViewContainer.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -kStackViewPadding).isActive = true
        mapViewContainer.bottomAnchor.constraint(equalTo: mapView.bottomAnchor).isActive = true
        
        descriptionTextfield.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextfield.defaultStyle()
        descriptionTextfield.placeholder = "Restaurant Description"
        descriptionTextfield.delegate = self
        descriptionView.addSubview(descriptionTextfield)
        descriptionView.applyAutoLayoutInsetsForAllMargins(to: descriptionTextfield, with: .zero)
        
        cuisineTypeTextfield.translatesAutoresizingMaskIntoConstraints = false
        cuisineTypeTextfield.defaultStyle()
        cuisineTypeTextfield.placeholder = "Cuisine Type"
        cuisineTypeTextfield.delegate = self
        cuisineTypeView.addSubview(cuisineTypeTextfield)
        cuisineTypeView.applyAutoLayoutInsetsForAllMargins(to: cuisineTypeTextfield, with: .zero)
        
        phoneNumberTextfield.translatesAutoresizingMaskIntoConstraints = false
        phoneNumberTextfield.defaultStyle()
        phoneNumberTextfield.placeholder = "Phone Number"
        phoneNumberTextfield.keyboardType = .numberPad
        phoneNumberTextfield.delegate = self
        phoneNumberView.addSubview(phoneNumberTextfield)
        phoneNumberView.applyAutoLayoutInsetsForAllMargins(to: phoneNumberTextfield, with: .zero)
        
        websiteTextfield.translatesAutoresizingMaskIntoConstraints = false
        websiteTextfield.defaultStyle()
        websiteTextfield.placeholder = "Website"
        websiteTextfield.keyboardType = .URL
        websiteTextfield.delegate = self
        websiteView.addSubview(websiteTextfield)
        websiteView.applyAutoLayoutInsetsForAllMargins(to: websiteTextfield, with: .zero)
        
        mapViewContainer.heightAnchor.constraint(equalToConstant: 300).isActive = true
        descriptionTextfield.heightAnchor.constraint(equalToConstant: kTextFieldHeight).isActive = true
        cuisineTypeTextfield.heightAnchor.constraint(equalToConstant: kTextFieldHeight).isActive = true
        phoneNumberTextfield.heightAnchor.constraint(equalToConstant: kTextFieldHeight).isActive = true
        websiteTextfield.heightAnchor.constraint(equalToConstant: kTextFieldHeight).isActive = true
        
        stackView.applyAutoLayoutInsetsForAllMargins(to: customViewContainer, with: .zero)
    }

    private func addValidationRules() {
        // none, for now
    }
}

extension UploadRestaurantIfNewTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UploadRestaurantIfNewTableViewCell: MKMapViewDelegate {
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        if !didMapInitiallyRender {
            didMapInitiallyRender = true
            setMapRegion()
        }
    }
    
    func addMapTrackingButton() {
        if mapView.userLocation.location?.coordinate != nil {
            let button = MKUserTrackingButton(mapView: mapView)
            button.translatesAutoresizingMaskIntoConstraints = false
            mapView.addSubview(button)
            
            button.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20).isActive = true
            button.bottomAnchor.constraint(equalTo: mapView.bottomAnchor,
                                           constant: -20).isActive = true
        }
    }
    
    func setMapRegion() {
        if let userCenter = mapView.userLocation.location?.coordinate {
            setMapCenter(backup: userCenter)
        } else {
            setMapCenter(backup: kWaterlooPlaza)
        }
    }
    
    private func setMapCenter(backup: CLLocationCoordinate2D) {
        let delta = 0.0025
        if let restaurantName = restaurantName {
            queryForRestaurant(restaurantName, around: backup) { (restaurantLoc) in
                if let restaurantLoc = restaurantLoc {
                    self.mapView.setRegion(MKCoordinateRegion(center: restaurantLoc,
                                                         span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)),
                                      animated: false)
                } else {
                    self.mapView.setRegion(MKCoordinateRegion(center: backup,
                                                         span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)),
                                      animated: false)
                }
            }
        } else {
            mapView.setRegion(MKCoordinateRegion(center: backup,
                                                 span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)),
                              animated: false)
        }
    }
    
    private func queryForRestaurant(_ name: String, around center: CLLocationCoordinate2D, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let delta = 0.0075

        let restaurantRequest = MKLocalSearch.Request()
        restaurantRequest.naturalLanguageQuery = name
        restaurantRequest.region = MKCoordinateRegion(center: center,
                                                      span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta))

        let restaurantSearch = MKLocalSearch(request: restaurantRequest)
        restaurantSearch.start { (response, _) in
            if let response = response {
                if response.mapItems.count > 0 {
                    completion(response.mapItems[0].placemark.coordinate)
                    return
                }
            }
            completion(nil)
        }
    }
}
