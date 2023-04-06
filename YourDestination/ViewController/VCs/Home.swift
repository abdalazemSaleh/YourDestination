//
//  Home.swift
//  YourDestination
//
//  Created by Abdalazem Saleh on 2023-02-19.
//

import UIKit
import MapKit

class Home: UIViewController {
    // MARK: - Variables
    var isButtonsContainerOpend: Bool = false
    var isTrackingUserLocation: Bool = false
    
    var constraint: [NSLayoutConstraint] = []
    
    let searchButton    = UIButton()
    let addButton       = UIButton()
    let discoverButton  = UIButton()
    
    var locationManger = CLLocationManager()
    
    // MARK: - IBOutlet
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var MenuView: UIView!
    @IBOutlet weak var menuStackView: UIStackView!
    @IBOutlet weak var menuHeight: NSLayoutConstraint!
    @IBOutlet weak var trakingUserLocation: UIButton!
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        MenuView.layer.cornerRadius = 16
        configureButtonsUI()
        configureGetMyLocationButtonUI()
        configureUserLocation()
        if let userLocation = locationManger.location {
            zoomToUserLocation(location: userLocation)
        }
    }
    // MARK: - IBAction
    @IBAction func more(_ sender: UIButton) {
        isButtonsContainerOpend.toggle()
        self.menuHeight.constant = self.isButtonsContainerOpend ? 176 : 32
        if isButtonsContainerOpend {
            UIView.animate(withDuration: 0.7) {
                self.menuStackView.addArrangedSubview(self.searchButton)
                self.menuStackView.addArrangedSubview(self.addButton)
                self.menuStackView.addArrangedSubview(self.discoverButton)
                self.view.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: 0.7) {
                self.searchButton.removeFromSuperview()
                self.addButton.removeFromSuperview()
                self.discoverButton.removeFromSuperview()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func trackingUserLocation(_ sender: UIButton) {
        isTrackingUserLocation.toggle()
        if isTrackingUserLocation {
            if let userLocation = locationManger.location {
                zoomToUserLocation(location: userLocation)
            }
            // Animate button to alert user
            UIView.animate(withDuration: 1.5, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction]) {
                self.trakingUserLocation.backgroundColor = .systemBlue
            }
        } else {
            UIView.animate(withDuration: 1) {
                self.trakingUserLocation.layer.removeAllAnimations()
                self.trakingUserLocation.backgroundColor = .secondarySystemBackground
            }
        }
    }
    
    // MARK: - Functions
    func configureGetMyLocationButtonUI() {
        trakingUserLocation.layer.cornerRadius = 24
    }
    
    func configureButtonsUI() {
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        searchButton.addTarget(self, action: #selector(search), for: .touchUpInside)
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        
        discoverButton.translatesAutoresizingMaskIntoConstraints = false
        discoverButton.setImage(UIImage(systemName: "aqi.medium"), for: .normal)

        constraint.append(searchButton.heightAnchor.constraint(equalToConstant: 32))
        constraint.append(searchButton.widthAnchor.constraint(equalToConstant: 32))
        
        constraint.append(addButton.heightAnchor.constraint(equalToConstant: 32))
        constraint.append(addButton.widthAnchor.constraint(equalToConstant: 32))

        constraint.append(discoverButton.heightAnchor.constraint(equalToConstant: 32))
        constraint.append(discoverButton.widthAnchor.constraint(equalToConstant: 32))
        
        NSLayoutConstraint.activate(constraint)
    }
    
    @objc private func search() {
        let vc = SearchVC()
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: false)
    }
}

// MARK: - Determine user location
extension Home: CLLocationManagerDelegate {
    private func configureUserLocation() {
        mapView.delegate = self
        
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        locationManger.allowsBackgroundLocationUpdates = true
        DispatchQueue.global().async {
            if self.isLocationServiceEnable() {
                DispatchQueue.main.async {
                    self.checkAuthorization()
                }
            } else {
                DispatchQueue.main.async {
                    self.showAlertMessage("Please enable location service to use MapKit.")
                }
            }
        }
    }
    
    private func isLocationServiceEnable() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    private func checkAuthorization() {
        switch locationManger.authorizationStatus {
        case .notDetermined:
            locationManger.requestAlwaysAuthorization()
        case .authorizedWhenInUse:
            locationManger.requestAlwaysAuthorization()
            locationManger.startUpdatingLocation()
            mapView.showsUserLocation = true
        case .authorizedAlways:
            locationManger.startUpdatingLocation()
            mapView.showsUserLocation = true
        case .denied:
            showAlertMessage("Please we need your auth to track your location.")
        case .restricted:
            showAlertMessage("Authorization Restricted")
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, isTrackingUserLocation else { return }
        zoomToUserLocation(location: location)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            locationManger.requestAlwaysAuthorization()
            locationManger.startUpdatingLocation()
            mapView.showsUserLocation = true
        case .authorizedAlways:
            locationManger.startUpdatingLocation()
            mapView.showsUserLocation = true
        case .denied:
            showAlertMessage("Please we need your auth to track your location.")
        default:
            break
        }
    }
    
    func zoomToUserLocation(location: CLLocation) {
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            mapView.setRegion(region , animated: true)
    }
}

// MARK: - Get destnation location
extension Home: getPlaceMark {
    func getCoordinate(_ placeMark: CLPlacemark) {
        guard let coordinate = placeMark.location else { return }
        let pin = MKPointAnnotation()
        mapView.removeAnnotation(pin)
        pin.coordinate = coordinate.coordinate
        pin.title      = placeMark.name
        pin.subtitle   = placeMark.country
        mapView.addAnnotation(pin)
        zoomToUserLocation(location: coordinate)
        if let userLocation = locationManger.location {
            drawDirections(startLocations: userLocation.coordinate, destnationLocation: coordinate.coordinate)
        }
    }
}

// MARK: - Draw path to my destnation
extension Home: MKMapViewDelegate {
    private func drawDirections(startLocations: CLLocationCoordinate2D, destnationLocation: CLLocationCoordinate2D) {
        let startingPlace = MKPlacemark(coordinate: startLocations)
        let destnationPlace = MKPlacemark(coordinate: destnationLocation)
        
        let startingItem = MKMapItem(placemark: startingPlace)
        let destnationItem = MKMapItem(placemark: destnationPlace)
        
        let request = MKDirections.Request()
        request.source = startingItem
        request.destination = destnationItem
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let response = response, error == nil else { return }
            
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .systemBlue
        return render
    }
}

