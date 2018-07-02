//
//  LocationViewController.swift
//  Bityo
//
//  Created by iOS Developer on 1/31/18.
//  Copyright © 2018 Chirag Ganatra. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import GooglePlaces

protocol LocationViewControllerDelegate {
    
    func sendLocation(location: CLLocationCoordinate2D)
    
}

class LocationViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var locationView: UIView!
    
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    
    @IBOutlet weak var txtSearch: UITextField!
    
    @IBOutlet weak var searchCloseBtn: UIButton!
    @IBOutlet weak var closeView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var textLabel: UILabel!
    
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    
    var sendLocation: CLLocationCoordinate2D?
    var user:FSUser!
    var locationManager = CLLocationManager()
    var fetcher: GMSAutocompleteFetcher?
    var tableData=[String]()
    let marker = GMSMarker()
    
    var delegate:LocationViewControllerDelegate?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if (UIScreen.main.nativeBounds.height == 2436) {
            headerTopConstraint.constant = -44.0
        }
        else {
            headerTopConstraint.constant = -20.0
        }
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        user = FSUserManager.sharedInstance.user!
        
        let tapBackGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapBack(_:)))
        //Add the recognizer to your view.
        backView.addGestureRecognizer(tapBackGesture)

        let tapSearchClose = UITapGestureRecognizer(target: self, action: #selector(self.searchCloseTapped(_:)))
        //Add the recognizer to your view.
        closeView.addGestureRecognizer(tapSearchClose)
        
        let neBoundsCorner = CLLocationCoordinate2D(latitude: 50.1375362543721,
                                                    longitude: -125.89274469763)
        let swBoundsCorner = CLLocationCoordinate2D(latitude: 22.9593629989521,
                                                    longitude: -67.1421004459262)
        let bounds = GMSCoordinateBounds(coordinate: neBoundsCorner,
                                         coordinate: swBoundsCorner)
        
        // Set up the autocomplete filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        
        // Create the fetcher.
        fetcher = GMSAutocompleteFetcher(bounds: bounds, filter: filter)
        fetcher?.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        searchCloseBtn.isHidden = true
        tableView.isHidden = true
        if (self.sendLocation == nil) {
            self.sendLocation = CLLocationCoordinate2D(latitude:CLLocationDegrees(self.user.lat), longitude:CLLocationDegrees(self.user.lng))
        }
        mapView.animate(toLocation: sendLocation!)
        mapView.animate(toZoom: 5.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func tapBack(_ sender:AnyObject){
        dismiss(animated: true, completion: nil)
    }

    @objc func searchCloseTapped(_ sender:AnyObject){
        txtSearch.text = ""
        searchCloseBtn.isHidden = true
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "addCategoryCell", for: indexPath) as! LocationCell
        cell.lblAddress?.text = tableData[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        txtSearch.text = tableData[indexPath.row]
        
        tableView.isHidden = true
        convertToCoordinate(address: tableData[indexPath.row])
    }
    
    func convertToCoordinate(address: String){
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {
                    // handle no location found
                    return
            }
            self.sendLocation = location.coordinate
            // Use your location
            self.mapView.animate(toLocation: location.coordinate)
        }
    }

    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        
        let myLocation = CLLocation(latitude: CLLocationDegrees(user.lat), longitude: CLLocationDegrees(user.lng))
        let distanceInMeters = myLocation.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
        let distanceInMiles = Int(distanceInMeters/160.9344)/10
        
        lblDistance.text = String(distanceInMiles) + " miles away"
        
        lblLocation.text = "Loading..."
        geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
            if let address = response?.firstResult() {
                let lines = address.lines as! [String]
                self.lblLocation.text = lines.joined(separator: "\n")
                
                let labelHeight = self.lblLocation.intrinsicContentSize.height
                self.mapView.padding = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0, bottom: labelHeight, right: 0)
                
                UIView.animate(withDuration: 0.25) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        print("update mapview")
        self.sendLocation = position.target
        reverseGeocodeCoordinate(coordinate: position.target)
        print(position.target.latitude, position.target.longitude)
    }

    func showMarker(position: CLLocationCoordinate2D){        
        marker.position = position
        marker.icon = #imageLiteral(resourceName: "map_pin")
        marker.map = self.mapView
    }
    
    //Location Manager delegates
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
        
        self.mapView?.animate(to: camera)
        //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D){
        marker.position = coordinate
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("didTapInfoWindowOf")
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: 200, height: 70))
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 6
        
        let lbl1 = UILabel(frame: CGRect.init(x: 8, y: 8, width: view.frame.size.width - 16, height: 15))
        lbl1.text = "Hi there!"
        view.addSubview(lbl1)
        
        let lbl2 = UILabel(frame: CGRect.init(x: lbl1.frame.origin.x, y: lbl1.frame.origin.y + lbl1.frame.size.height + 3, width: view.frame.size.width - 16, height: 15))
        lbl2.text = "I am a custom info window."
        lbl2.font = UIFont.systemFont(ofSize: 14, weight: .light)
        view.addSubview(lbl2)
        
        return view
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    @IBAction func searchBegin(_ sender: Any) {
        searchCloseBtn.isHidden = false
    }
    
    @IBAction func searchEnded(_ sender: Any) {
        searchCloseBtn.isHidden = true
    }
    
    @IBAction func searchTxtChanged(_ sender: UITextField) {
        if sender.text != "" {
            searchCloseBtn.isHidden = false
            tableView.isHidden = false
        }
        fetcher?.sourceTextHasChanged(sender.text!)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("return pressed")
        textField.resignFirstResponder()
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func onBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSearchClose(_ sender: Any) {
        txtSearch.text = ""
        searchCloseBtn.isHidden = true
    }
    
    @IBAction func onSend(_ sender: Any) {
        dismiss(animated: true) {
            
            print("send location")
            self.delegate?.sendLocation(location: self.sendLocation!)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LocationViewController: GMSAutocompleteFetcherDelegate {
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        tableData.removeAll()
        
        for prediction in predictions {
            
            tableData.append(prediction.attributedPrimaryText.string)
            
            //print("\n",prediction.attributedFullText.string)
            //print("\n",prediction.attributedPrimaryText.string)
            //print("\n********")
        }
        
        tableView.reloadData()
    }
    
    func didFailAutocompleteWithError(_ error: Error) {
        //resultText?.text = error.localizedDescription
        print(error.localizedDescription)
    }
}

class LocationCell: UITableViewCell {
    
    @IBOutlet weak var lblAddress: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

