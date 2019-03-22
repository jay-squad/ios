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

protocol UploadRestaurantIfNewTableViewCellDelegate: class {
    func onMapUnlockGiveTableViewHeight() -> CGFloat
    func onMapLock()
}

class UploadRestaurantIfNewTableViewCell: FormComponentTableViewCell {

    private let kWaterlooPlaza = CLLocationCoordinate2D(latitude: 43.4721862, longitude: -80.5376677)
    private let kMapViewContainerSmallHeight: CGFloat = 300
    private let kMapViewContainerLargeHeight: CGFloat = 500
    private let kMapViewLabelToMapViewSpacing: CGFloat = 10
    private let kFormStackViewSpacing: CGFloat = 24
    
    private let stackView = UIStackView()
    private let descriptionView = UIView()
    private let cuisineTypeView = UIView()
    private let phoneNumberView = UIView()
    private let websiteView = UIView()
    private let dummyView = UIView()

    let descriptionTextfield = HoshiTextField()
    let phoneNumberTextfield = HoshiTextField()
    let websiteTextfield = HoshiTextField()
    let cuisineTypeTextfield = HoshiTextField()
    
    private let mapViewContainerContainer = UIView()
    let mapView = MKMapView()
    private let mapViewLabel = UILabel()
    private let mapViewButtonPositive = UIButton()
    private let mapViewButtonNegative = UIButton()
    private let mapViewActivityIndicator = UIActivityIndicatorView()
    
    var restaurantName: String?
    
    private var locationManager = CLLocationManager()
    private var didMapInitiallyRender: Bool = false
    private var mapCenterIfCancelTapped: CLLocationCoordinate2D?
    private var mapViewContainerContainerTopConstraint: NSLayoutConstraint?
    private var mapViewContainerContainerBottomConstraint: NSLayoutConstraint?
    private var mapViewContainerHeightConstraint: NSLayoutConstraint?
    
    weak var delegate: UploadRestaurantIfNewTableViewCellDelegate?
    
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
        mapView.isUserInteractionEnabled = false
        addMapTrackingButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addValidationRules()
    }
    
    override func buildComponents() {
        super.buildComponents()
        clipsToBounds = false
        layer.zPosition = 99
        setCellHeader(title: "Create a New Restaurant", subtitle: "Optionally fill out additional details about the restaurant.")
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = kFormStackViewSpacing
       
        let mapViewContainer = UIView()

        mapViewContainerContainer.translatesAutoresizingMaskIntoConstraints = false
        mapViewContainer.translatesAutoresizingMaskIntoConstraints = false
        descriptionView.translatesAutoresizingMaskIntoConstraints = false
        cuisineTypeView.translatesAutoresizingMaskIntoConstraints = false
        phoneNumberView.translatesAutoresizingMaskIntoConstraints = false
        websiteView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(mapViewContainerContainer)
        stackView.addArrangedSubview(descriptionView)
        stackView.addArrangedSubview(cuisineTypeView)
        stackView.addArrangedSubview(websiteView)
        stackView.addArrangedSubview(phoneNumberView)
        customViewContainer.addSubview(stackView)
        
        stackView.bringSubviewToFront(mapViewContainerContainer)
        mapViewLabel.translatesAutoresizingMaskIntoConstraints = false
        mapViewLabel.font = UIFont(font: .helveticaNeueBold, size: 14)
        
        mapViewButtonPositive.translatesAutoresizingMaskIntoConstraints = false
        mapViewButtonPositive.titleLabel?.font = UIFont(font: .helveticaNeueBold, size: 16)
        mapViewButtonPositive.addTarget(self, action: #selector(onMapViewButtonPositiveTapped), for: .touchUpInside)
        mapViewButtonPositive.layer.cornerRadius = 5.0
        mapViewButtonPositive.backgroundColor = UIColor.cc253UltraLightGrey
        mapViewButtonPositive.applyDefaultShadow()
        
        mapViewButtonNegative.translatesAutoresizingMaskIntoConstraints = false
        mapViewButtonNegative.titleLabel?.font = UIFont(font: .helveticaNeueBold, size: 16)
        mapViewButtonNegative.addTarget(self, action: #selector(onMapViewButtonNegativeTapped), for: .touchUpInside)
        mapViewButtonNegative.layer.cornerRadius = 5.0
        mapViewButtonNegative.backgroundColor = UIColor.cc253UltraLightGrey
        mapViewButtonNegative.applyDefaultShadow()
        
        setMapViewToQuestions()
        
        mapViewActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        mapViewActivityIndicator.style = .gray
        mapViewActivityIndicator.isUserInteractionEnabled = false
        mapViewActivityIndicator.hidesWhenStopped = true
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        
        mapViewContainerContainer.addSubview(mapViewContainer)
        mapViewContainerContainer.leadingAnchor.constraint(equalTo: mapViewContainer.leadingAnchor).isActive = true
        mapViewContainerContainer.trailingAnchor.constraint(equalTo: mapViewContainer.trailingAnchor).isActive = true
        mapViewContainerContainerTopConstraint = mapViewContainerContainer.topAnchor.constraint(equalTo: mapViewContainer.topAnchor)
        mapViewContainerContainerTopConstraint?.isActive = true
        mapViewContainerContainerBottomConstraint = mapViewContainerContainer.bottomAnchor.constraint(equalTo: mapViewContainer.bottomAnchor)
        mapViewContainerContainerBottomConstraint?.isActive = true
        mapViewContainerContainerTopConstraint?.isActive = true
        
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
        mapViewContainer.addSubview(mapViewButtonPositive)
        mapViewContainer.addSubview(mapViewButtonNegative)
        mapViewContainer.addSubview(mapViewActivityIndicator)
        mapViewContainer.leadingAnchor.constraint(equalTo: mapViewLabel.leadingAnchor).isActive = true
        mapViewContainer.trailingAnchor.constraint(equalTo: mapViewLabel.trailingAnchor).isActive = true
        mapViewContainer.topAnchor.constraint(equalTo: mapViewLabel.topAnchor).isActive = true
        mapViewLabel.bottomAnchor.constraint(equalTo: mapView.topAnchor, constant: -kMapViewLabelToMapViewSpacing).isActive = true
        mapViewCenterMarker.centerXAnchor.constraint(equalTo: mapView.centerXAnchor).isActive = true
        mapViewCenterMarker.centerYAnchor.constraint(equalTo: mapView.centerYAnchor, constant: -kMapViewCenterMarkerHeight/2).isActive = true
        mapViewActivityIndicator.centerXAnchor.constraint(equalTo: mapView.centerXAnchor).isActive = true
        mapViewActivityIndicator.centerYAnchor.constraint(equalTo: mapView.centerYAnchor, constant: 30).isActive = true
        
        mapViewContainer.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: kStackViewPadding).isActive = true
        mapViewContainer.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -kStackViewPadding).isActive = true
        mapViewContainer.bottomAnchor.constraint(equalTo: mapView.bottomAnchor).isActive = true
        
        mapViewButtonPositive.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 10).isActive = true
        mapViewButtonNegative.topAnchor.constraint(equalTo: mapViewButtonPositive.topAnchor).isActive = true
        mapViewButtonPositive.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 10).isActive = true
        mapViewButtonPositive.trailingAnchor.constraint(equalTo: mapViewButtonNegative.leadingAnchor, constant: -10).isActive = true
        mapViewButtonNegative.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -10).isActive = true
        mapViewButtonNegative.widthAnchor.constraint(equalTo: mapViewButtonPositive.widthAnchor).isActive = true
        mapViewButtonNegative.heightAnchor.constraint(equalTo: mapViewButtonPositive.heightAnchor).isActive = true
        mapViewButtonPositive.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        descriptionTextfield.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextfield.defaultStyle()
        descriptionTextfield.placeholder = "Restaurant Description"
        descriptionTextfield.tag = UploadFormComponent.restaurantDescription.rawValue
        descriptionTextfield.delegate = self
        descriptionTextfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        descriptionView.addSubview(descriptionTextfield)
        descriptionView.applyAutoLayoutInsetsForAllMargins(to: descriptionTextfield, with: .zero)
        
        cuisineTypeTextfield.translatesAutoresizingMaskIntoConstraints = false
        cuisineTypeTextfield.defaultStyle()
        cuisineTypeTextfield.placeholder = "Cuisine Type"
        cuisineTypeTextfield.tag = UploadFormComponent.restaurantCuisineType.rawValue
        cuisineTypeTextfield.delegate = self
        cuisineTypeTextfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        cuisineTypeView.addSubview(cuisineTypeTextfield)
        cuisineTypeView.applyAutoLayoutInsetsForAllMargins(to: cuisineTypeTextfield, with: .zero)
        
        phoneNumberTextfield.translatesAutoresizingMaskIntoConstraints = false
        phoneNumberTextfield.defaultStyle()
        phoneNumberTextfield.placeholder = "Phone Number"
        phoneNumberTextfield.tag = UploadFormComponent.restaurantPhoneNumber.rawValue
        phoneNumberTextfield.keyboardType = .numberPad
        phoneNumberTextfield.delegate = self
        phoneNumberTextfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        phoneNumberView.addSubview(phoneNumberTextfield)
        phoneNumberView.applyAutoLayoutInsetsForAllMargins(to: phoneNumberTextfield, with: .zero)
        
        websiteTextfield.translatesAutoresizingMaskIntoConstraints = false
        websiteTextfield.defaultStyle()
        websiteTextfield.placeholder = "Website"
        websiteTextfield.tag = UploadFormComponent.restaurantWebsite.rawValue
        websiteTextfield.keyboardType = .URL
        websiteTextfield.delegate = self
        websiteTextfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        websiteView.addSubview(websiteTextfield)
        websiteView.applyAutoLayoutInsetsForAllMargins(to: websiteTextfield, with: .zero)
        
        mapViewContainerHeightConstraint = mapViewContainer.heightAnchor.constraint(equalToConstant: kMapViewContainerSmallHeight)
        mapViewContainerHeightConstraint?.priority = .defaultLow
        mapViewContainerHeightConstraint?.isActive = true
        descriptionTextfield.heightAnchor.constraint(equalToConstant: kTextFieldHeight).isActive = true
        cuisineTypeTextfield.heightAnchor.constraint(equalToConstant: kTextFieldHeight).isActive = true
        phoneNumberTextfield.heightAnchor.constraint(equalToConstant: kTextFieldHeight).isActive = true
        websiteTextfield.heightAnchor.constraint(equalToConstant: kTextFieldHeight).isActive = true
        
        stackView.applyAutoLayoutInsetsForAllMargins(to: customViewContainer, with: .zero)
    }

    private func addValidationRules() {
        // none, for now
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        formComponentDelegate?.onTextFieldUpdated(textField)
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
                self.setMapViewToQuestions()
            }
        } else {
            mapView.setRegion(MKCoordinateRegion(center: backup,
                                                 span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)),
                              animated: false)
            setMapViewToQuestions()
        }
    }
    
    private func queryForRestaurant(_ name: String, around center: CLLocationCoordinate2D, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let delta = 0.0075

        let restaurantRequest = MKLocalSearch.Request()
        restaurantRequest.naturalLanguageQuery = name
        restaurantRequest.region = MKCoordinateRegion(center: center,
                                                      span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta))

        mapViewActivityIndicator.startAnimating()
        let restaurantSearch = MKLocalSearch(request: restaurantRequest)
        restaurantSearch.start { (response, _) in
            self.mapViewActivityIndicator.stopAnimating()
            if let response = response {
                if response.mapItems.count > 0 {
                    completion(response.mapItems[0].placemark.coordinate)
                    return
                }
            }
            completion(nil)
        }
    }
    
    @objc private func onMapViewButtonPositiveTapped() {
        switch mapViewButtonPositive.titleLabel?.text {
        case "Yes", "Done":
            setMapViewToLockedMode()
        case "Change":
            setMapViewToUnlockedMode()
        default:
            break
        }
        
    }
    
    @objc private func onMapViewButtonNegativeTapped() {
        switch mapViewButtonNegative.titleLabel?.text {
        case "No":
            setMapViewToUnlockedMode()
        case "Cancel":
            if let center = mapCenterIfCancelTapped {
                var curRegion = mapView.region
                curRegion.center = center
                mapView.setRegion(curRegion, animated: true)
            }
            setMapViewToLockedMode()
        default:
            break
        }
    }
    
    private func setMapViewToUnlockedMode() {
        mapCenterIfCancelTapped = mapView.centerCoordinate
        mapViewLabel.text = "Set the restaurant location"
        mapViewButtonPositive.setTitleColor(UIColor.ccMoneyGreen, for: .normal)
        mapViewButtonPositive.setTitle("Done", for: .normal)
        mapViewButtonNegative.setTitleColor(UIColor.cc74MediumGrey, for: .normal)
        mapViewButtonNegative.setTitle("Cancel", for: .normal)
        mapViewButtonNegative.isHidden = false
        mapView.isUserInteractionEnabled = true
        
        if let tableViewHeight = delegate?.onMapUnlockGiveTableViewHeight() {
            hideTextFields()
            let otherHeights = titleStackView.frame.height + mapViewLabel.frame.height + kContainerStackViewSpacing*2 + kMapViewLabelToMapViewSpacing - kFormStackViewSpacing
            mapViewContainerHeightConstraint?.constant = tableViewHeight - otherHeights
            UIView.animate(withDuration: 0.2) {
                self.contentView.layoutIfNeeded()
            }
        }
    }
    
    private func setMapViewToLockedMode() {
        mapViewLabel.text = "Change restaurant location if needed"
        mapViewButtonPositive.setTitleColor(UIColor.cc74MediumGrey, for: .normal)
        mapViewButtonPositive.setTitle("Change", for: .normal)
        mapViewButtonNegative.isHidden = true
        mapView.isUserInteractionEnabled = false
        delegate?.onMapLock()
        showTextFields()
        formComponentDelegate?.onMapUpdated(mapView)
        mapViewContainerHeightConstraint?.constant = kMapViewContainerSmallHeight
        UIView.animate(withDuration: 0.2) {
            self.contentView.layoutIfNeeded()
        }
    }
    
    private func setMapViewToQuestions() {
        mapViewLabel.text = "Is this restaurant's location correct?"
        mapViewButtonPositive.setTitle("Yes", for: .normal)
        mapViewButtonPositive.setTitleColor(UIColor.ccMoneyGreen, for: .normal)
        mapViewButtonNegative.setTitle("No", for: .normal)
        mapViewButtonNegative.setTitleColor(UIColor.ccErrorRed, for: .normal)
        mapViewButtonNegative.isHidden = false
        mapView.isUserInteractionEnabled = false
        delegate?.onMapLock()
        showTextFields()
        mapViewContainerHeightConstraint?.constant = kMapViewContainerSmallHeight
        UIView.animate(withDuration: 0.2) {
            self.contentView.layoutIfNeeded()
        }
    }
    
    private func hideTextFields() {
        if descriptionView.superview != nil {
            self.descriptionView.removeFromSuperview()
            self.phoneNumberView.removeFromSuperview()
            self.websiteView.removeFromSuperview()
            self.cuisineTypeView.removeFromSuperview()
            self.stackView.addArrangedSubview(dummyView)
            UIView.animate(withDuration: 0.2) {
                self.descriptionView.alpha = 0
                self.phoneNumberView.alpha = 0
                self.websiteView.alpha = 0
                self.cuisineTypeView.alpha = 0
            }
        }
    }
    
    private func showTextFields() {
        if descriptionView.superview == nil {
            self.stackView.addArrangedSubview(self.descriptionView)
            self.stackView.addArrangedSubview(self.cuisineTypeView)
            self.stackView.addArrangedSubview(self.websiteView)
            self.stackView.addArrangedSubview(self.phoneNumberView)
            dummyView.removeFromSuperview()
            UIView.animate(withDuration: 0.2) {
                self.descriptionView.alpha = 1
                self.phoneNumberView.alpha = 1
                self.websiteView.alpha = 1
                self.cuisineTypeView.alpha = 1
            }
        }
    }
}
