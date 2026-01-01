//
//  ConfirmLocationViewController.swift
//  Ataya
//
//  Created by BP-36-224-16 on 20/12/2025.
//
import UIKit
import MapKit
import CoreLocation

final class ConfirmLocationViewController: UIViewController {

    @IBOutlet weak var currentAddressField: UIView!
    @IBOutlet weak var txtReadOnlyLocation: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var confirmbtn: UIButton!

    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    private let centerPin = UIImageView(image: UIImage(systemName: "mappin.circle.fill"))

    private var hasCenteredOnGPS = false
    private var lastGeocodeCenter: CLLocationCoordinate2D?
    private var lastAddress: String = "Move map to pick location..."
    private var lastCoordinate: CLLocationCoordinate2D?

    private let yellow = UIColor(hex: "#F7D44C")

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Confirm Location"

        LocationStorage.clear()

        setupUI()
        setupMap()
        setupLocation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self else { return }
            if self.lastCoordinate == nil {
                let fallback = CLLocationCoordinate2D(latitude: 26.0667, longitude: 50.5577)
                let region = MKCoordinateRegion(center: fallback, latitudinalMeters: 20000, longitudinalMeters: 20000)
                self.mapView.setRegion(region, animated: true)
                self.updateAddressFromMapCenter(force: true)
            }
        }
    }

    private func setupUI() {
        currentAddressField.backgroundColor = .white
        currentAddressField.layer.cornerRadius = 16
        currentAddressField.layer.shadowColor = UIColor.black.cgColor
        currentAddressField.layer.shadowOpacity = 0.10
        currentAddressField.layer.shadowRadius = 10
        currentAddressField.layer.shadowOffset = CGSize(width: 0, height: 4)
        currentAddressField.layer.masksToBounds = false

        confirmbtn.backgroundColor = yellow
        confirmbtn.setTitleColor(.black, for: .normal)
        confirmbtn.layer.cornerRadius = 8
        confirmbtn.clipsToBounds = true

        txtReadOnlyLocation.isUserInteractionEnabled = false
        txtReadOnlyLocation.borderStyle = .roundedRect
        txtReadOnlyLocation.text = lastAddress
    }

    private func setupMap() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.showsCompass = true

        centerPin.tintColor = yellow
        centerPin.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(centerPin)

        NSLayoutConstraint.activate([
            centerPin.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
            centerPin.centerYAnchor.constraint(equalTo: mapView.centerYAnchor, constant: -18),
            centerPin.widthAnchor.constraint(equalToConstant: 36),
            centerPin.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    private func setupLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        guard CLLocationManager.locationServicesEnabled() else {
            txtReadOnlyLocation.text = "Location Services OFF. Move map to pick."
            return
        }

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()

        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()

        case .denied, .restricted:
            txtReadOnlyLocation.text = "Location denied. Move map to pick."

        @unknown default:
            txtReadOnlyLocation.text = "Unknown permission. Move map to pick."
        }
    }

    private func updateAddressFromMapCenter(force: Bool = false) {
        let center = mapView.centerCoordinate
        lastCoordinate = center

        if !force, let last = lastGeocodeCenter {
            if distanceMeters(from: last, to: center) < 25 { return }
        }
        lastGeocodeCenter = center

        let loc = CLLocation(latitude: center.latitude, longitude: center.longitude)

        geocoder.cancelGeocode()
        geocoder.reverseGeocodeLocation(loc) { [weak self] placemarks, _ in
            guard let self else { return }

            guard let p = placemarks?.first else {
                self.lastAddress = "Unknown address (move map)"
                DispatchQueue.main.async { self.txtReadOnlyLocation.text = self.lastAddress }
                return
            }

            let parts = [p.name, p.subLocality, p.locality, p.administrativeArea].compactMap { $0 }
            self.lastAddress = parts.isEmpty ? "Unknown address" : parts.joined(separator: ", ")

            DispatchQueue.main.async {
                self.txtReadOnlyLocation.text = self.lastAddress
            }
        }
    }

    private func distanceMeters(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        CLLocation(latitude: from.latitude, longitude: from.longitude)
            .distance(from: CLLocation(latitude: to.latitude, longitude: to.longitude))
    }

    @IBAction func confirmTapped(_ sender: Any) {
        guard let coord = lastCoordinate else {
            txtReadOnlyLocation.text = "Location not ready yet."
            return
        }

        LocationStorage.save(latitude: coord.latitude, longitude: coord.longitude, address: lastAddress)
        navigationController?.popViewController(animated: true)
    }
}

extension ConfirmLocationViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        setupLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLoc = locations.last else { return }

        if !hasCenteredOnGPS {
            hasCenteredOnGPS = true
            let region = MKCoordinateRegion(center: userLoc.coordinate, latitudinalMeters: 800, longitudinalMeters: 800)
            mapView.setRegion(region, animated: true)
            updateAddressFromMapCenter(force: true)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        txtReadOnlyLocation.text = "GPS not available. Move map to pick."
    }
}

extension ConfirmLocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        updateAddressFromMapCenter()
    }
}
