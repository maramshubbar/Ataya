//
//  ConfirmLocationViewController.swift
//  Ataya
//
//  Created by BP-36-224-16 on 20/12/2025.
//

import UIKit
import MapKit
import CoreLocation

class ConfirmLocationViewController: UIViewController {

    @IBAction func confirmTapped(_ sender: Any) {
        guard let coord = lastCoordinate else {
                txtReadOnlyLocation.text = "Location not ready yet."
                return
            }

            let saved = savedLocation(
                latitude: coord.latitude,
                longitude: coord.longitude,
                address: lastAddress,
                savedAt: Date()
            )

            locationStorage.save(saved)

            navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var currentAddressField: UIView!
    @IBOutlet weak var txtReadOnlyLocation: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var confirmbtn: UIButton!

        private let locationManager = CLLocationManager()
        private let geocoder = CLGeocoder()

        // Center pin (old style)
        private let centerPin = UIImageView(image: UIImage(systemName: "mappin.circle.fill"))

        // state
        private var hasCenteredOnGPS = false
        private var lastGeocodeCenter: CLLocationCoordinate2D?
        private var lastAddress: String = "Move map to pick location..."
        private var lastCoordinate: CLLocationCoordinate2D?

        private let yellow = UIColor(hex: "#FEC400")

        override func viewDidLoad() {
            super.viewDidLoad()
            title = "Confirm Location"

            setupUI()
            setupMap()
            setupLocation()

            // If GPS doesn't come, still allow user to move map and pick.
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                guard let self = self else { return }
                if self.lastCoordinate == nil {
                    // Set a default coordinate (Bahrain) so pin works even with no GPS
                    let fallback = CLLocationCoordinate2D(latitude: 26.0667, longitude: 50.5577) // Manama-ish
                    self.mapView.setRegion(
                        MKCoordinateRegion(center: fallback, latitudinalMeters: 20000, longitudinalMeters: 20000),
                        animated: true
                    )
                    self.updateAddressFromMapCenter(force: true)
                }
            }
        }

        // MARK: - UI
        private func setupUI() {
            // Card style
            currentAddressField.backgroundColor = .white
            currentAddressField.layer.cornerRadius = 16
            currentAddressField.layer.shadowColor = UIColor.black.cgColor
            currentAddressField.layer.shadowOpacity = 0.10
            currentAddressField.layer.shadowRadius = 10
            currentAddressField.layer.shadowOffset = CGSize(width: 0, height: 4)
            currentAddressField.layer.masksToBounds = false

            // Confirm button
            confirmbtn.backgroundColor = yellow
            confirmbtn.setTitleColor(.black, for: .normal)
            confirmbtn.layer.cornerRadius = 8
            confirmbtn.clipsToBounds = true

            // Read-only field
            txtReadOnlyLocation.isUserInteractionEnabled = false
            txtReadOnlyLocation.borderStyle = .roundedRect
            txtReadOnlyLocation.text = lastAddress
        }

        // MARK: - Map
        private func setupMap() {
            mapView.delegate = self
            mapView.showsUserLocation = true
            mapView.showsCompass = true

            // Center pin overlay (old style)
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

        // MARK: - Location
        private func setupLocation() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest

            guard CLLocationManager.locationServicesEnabled() else {
                txtReadOnlyLocation.text = "Location Services are OFF. Move map to pick location."
                return
            }

            switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()

            case .authorizedWhenInUse, .authorizedAlways:
                // ✅ Request ONE GPS fix (better than continuous for this screen)
                locationManager.requestLocation()

            case .denied, .restricted:
                txtReadOnlyLocation.text = "Location denied. Move map to pick location."

            @unknown default:
                txtReadOnlyLocation.text = "Unknown permission state. Move map to pick location."
            }
        }

        // MARK: - Reverse geocode map center
        private func updateAddressFromMapCenter(force: Bool = false) {
            let center = mapView.centerCoordinate
            lastCoordinate = center

            // throttle geocoder
            if !force, let last = lastGeocodeCenter {
                let moved = distanceMeters(from: last, to: center)
                if moved < 25 { return }
            }
            lastGeocodeCenter = center

            let loc = CLLocation(latitude: center.latitude, longitude: center.longitude)

            geocoder.cancelGeocode()
            geocoder.reverseGeocodeLocation(loc) { [weak self] placemarks, _ in
                guard let self = self else { return }

                guard let p = placemarks?.first else {
                    self.lastAddress = "Unknown address (move map)"
                    DispatchQueue.main.async { self.txtReadOnlyLocation.text = self.lastAddress }
                    return
                }

                let parts = [p.name, p.subLocality, p.locality, p.administrativeArea]
                    .compactMap { $0 }

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
    }

    // MARK: - CLLocationManagerDelegate
    extension ConfirmLocationViewController: CLLocationManagerDelegate {

        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            setupLocation()
        }

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let userLoc = locations.last else { return }

            // ✅ only center once on GPS
            if !hasCenteredOnGPS {
                hasCenteredOnGPS = true

                let region = MKCoordinateRegion(center: userLoc.coordinate,
                                                latitudinalMeters: 800,
                                                longitudinalMeters: 800)
                mapView.setRegion(region, animated: true)

                // update address for center (now it will be near your GPS)
                updateAddressFromMapCenter(force: true)
            }
        }

        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            // If GPS fails, user can still move map manually with center pin
            txtReadOnlyLocation.text = "GPS not available. Move map to pick location."
        }
    }

    // MARK: - MKMapViewDelegate
    extension ConfirmLocationViewController: MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            updateAddressFromMapCenter()
        }
    }

    // MARK: - Hex helper
    private extension UIColor {
        convenience init(hex: String) {
            var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            if s.hasPrefix("#") { s.removeFirst() }
            var rgb: UInt64 = 0
            Scanner(string: s).scanHexInt64(&rgb)
            self.init(
                red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgb & 0x0000FF) / 255.0,
                alpha: 1.0
            )
        }
    }
