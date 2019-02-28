//
//  MapViewController.swift
//  foodie
//
//  Created by Austin Du on 2019-01-08.
//  Copyright © 2019 JAY. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    var mapview: MKMapView = MKMapView(frame: .zero)
    var locationManager = CLLocationManager()
    
    var annotations: [CLLocationCoordinate2D: MKAnnotation] = [:]
    var mapItems: [CLLocationCoordinate2D: MKMapItem] = [:]
    
    var didMapInitiallyRender: Bool = false
    
    var modalView: MapRestaurantModalView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildComponents()
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        mapview.showsUserLocation = true
        mapview.delegate = self
    }
    
    private func buildComponents() {
        let externalContainerView = UIView()
        externalContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(externalContainerView)
        view.applyAutoLayoutInsetsForAllMargins(to: externalContainerView, with: .zero)
        
        mapview.translatesAutoresizingMaskIntoConstraints = false
        externalContainerView.addSubview(mapview)
        externalContainerView.applyAutoLayoutInsetsForAllMargins(to: mapview, with: .zero)
        
        addMapTrackingButton()
    }
    
    func addMapTrackingButton() {
        let button = MKUserTrackingButton(mapView: mapview)
        button.translatesAutoresizingMaskIntoConstraints = false
        mapview.addSubview(button)
        
        let tabBarHeight = self.tabBarController?.tabBar.frame.height ?? 0
        
        button.trailingAnchor.constraint(equalTo: mapview.trailingAnchor, constant: -20).isActive = true
        button.bottomAnchor.constraint(equalTo: mapview.bottomAnchor,
                                       constant: -20 - tabBarHeight).isActive = true
        
    }

}

extension MapViewController: MKMapViewDelegate {
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        if !didMapInitiallyRender {
            didMapInitiallyRender = true
            let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 250, longitudinalMeters: 250)
            mapView.setRegion(mapView.regionThatFits(region), animated: false)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let restaurantRequest = MKLocalSearch.Request()
        restaurantRequest.naturalLanguageQuery = "restaurant"
        restaurantRequest.region = mapView.region
        
        let restaurantSearch = MKLocalSearch(request: restaurantRequest)
        restaurantSearch.start { (response, _) in
//            print(response)
            if let response = response {
                for mapItem in response.mapItems where !(self.annotations[mapItem.placemark.coordinate] != nil) {
                    if mapItem.isCurrentLocation { continue; }
                    let point = MKPointAnnotation()
                    point.coordinate = mapItem.placemark.coordinate
                    point.title = mapItem.name
                    self.mapItems[mapItem.placemark.coordinate] = mapItem
                    self.annotations[mapItem.placemark.coordinate] = point
                }
                
                mapView.addAnnotations(Array(self.annotations.values.map { $0 }))
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        if annotations[annotation.coordinate] != nil {
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            annotationView.markerTintColor = UIColor.ccPendingBlue
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let modalWidth: CGFloat = UIScreen.main.bounds.width - 20
        let modalHeight: CGFloat = 120
        
        if modalView == nil {
            modalView = MapRestaurantModalView(frame: .zero)
            mapView.addSubview(modalView!)
            modalView?.translatesAutoresizingMaskIntoConstraints = false
            modalView?.widthAnchor.constraint(equalToConstant: modalWidth).isActive = true
            modalView?.heightAnchor.constraint(equalToConstant: modalHeight).isActive = true
            let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
            modalView?.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -tabBarHeight - 10).isActive = true
            modalView?.centerXAnchor.constraint(equalTo: mapView.centerXAnchor).isActive = true
        }
        
        if let annotation = view.annotation,
            let title = annotation.title,
            let address = mapItems[annotation.coordinate]?.placemark.title {
            modalView?.configureView(title: title, description: address, address: address)
//            takeSnapShot(location: annotation.coordinate, width: modalWidth, height: modalHeight)
        }
    }
    
//    func takeSnapShot(location: CLLocationCoordinate2D, width: CGFloat, height: CGFloat) {
//        let mapSnapshotOptions = MKMapSnapshotter.Options()
//
//        // Set the region of the map that is rendered. (by one specified coordinate)
//        // let location = CLLocationCoordinate2DMake(24.78423, 121.01836) // Apple HQ
////        let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
//
//        // Set the region of the map that is rendered. (by polyline)
//        // var yourCoordinates = [CLLocationCoordinate2D]()  <- initinal this array with your polyline coordinates
////        let polyLine = MKPolyline(coordinates: &yourCoordinates, count: yourCoordinates.count)
////        let region = MKCoordinateRegionForMapRect(polyLine.boundingMapRect)
//
////        mapSnapshotOptions.region = region
//
//        // Set the scale of the image. We'll just use the scale of the current device, which is 2x scale on Retina screens.
//        mapSnapshotOptions.scale = UIScreen.main.scale
//
//        // Set the size of the image output.
//        mapSnapshotOptions.size = CGSize(width: width, height: height)
//
//        // Show buildings and Points of Interest on the snapshot
//        mapSnapshotOptions.showsBuildings = true
//        mapSnapshotOptions.showsPointsOfInterest = true
//        mapSnapshotOptions.mapType = .satelliteFlyover
//        mapSnapshotOptions.camera = MKMapCamera(lookingAtCenter: location, fromDistance: 3000, pitch: 65, heading: 0)
//
//        let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)
//
//        snapShotter.start() { snapshot, error in
//            guard let snapshot = snapshot else {
//                return
//            }
//            self.modalView?.configureImage(image: snapshot.image)
//        }
//    }
    
}

// To use CLLocationCoordinate2D as a key in a dictionary, it needs to comply with the Hashable protocol
extension CLLocationCoordinate2D: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}

// To be Hashable, you need to be Equatable too
public func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}
