//
//  FeedsViewController.swift
//  Bityo
//
//  Created by Chirag Ganatra on 29/11/17.
//  Copyright © 2017 Chirag Ganatra. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import Crashlytics

class FeedsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var collectionFeeds: UICollectionView!
    @IBOutlet weak var collectionCategory: UICollectionView!
    
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var closeButtonView: UIView!
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var avatarImgView: FSImageView!
    @IBOutlet weak var filterView: UIView!    
    
    var resultFeeds:[DataSnapshot] = []
    var searchFeeds:[DataSnapshot] = []
    var selectCat:String = ""
    var selectSubCat:String = ""
    var user:FSUser?
    
    //location manager
    private let locationManager = LocationManager.shared
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (FSUserManager.sharedInstance.user != nil) {
            FSUserManager.sharedInstance.registerFirebaseToken()
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        user = FSUserManager.sharedInstance.user!
        setupUI()
        

//        collectionFeeds.contentInset = UIEdgeInsetsMake(10, 10, 0, 10)
        getFeeds()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func setupUI() {
        
        if user?.type == "develop" {
            btnPlus.isHidden = false
        }
        else {
            btnPlus.isHidden = true
        }
        collectionCategory.isHidden = true
        UIApplication.shared.statusBarStyle = .default
        
        if ((user?.avatarImage) != nil)
        {
            avatarImgView.image = user?.avatarImage
        }
        else {
            if (user?.imgUrl != nil)
            {
                avatarImgView.showLoading()
                Utilities.downloadImage(url: (user?.imgUrl)!, completion: {(avatarImage) in
                    self.avatarImgView.hideLoading()
                    FSUserManager.sharedInstance.user?.avatarImage = avatarImage
                    self.avatarImgView.image = avatarImage
                },
                    failure: {(errorComment: String) -> Void in
                        self.avatarImgView.hideLoading()
                })
            }
            else {
                self.avatarImgView.image = UIImage(named: "user_default")
            }
        }
        
        let tapProfileGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapProfile))
        avatarImgView.addGestureRecognizer(tapProfileGesture)
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            refreshControl.tintColor = UIColor(rgb: 0xFECD24, a: 1.0)
            collectionFeeds.refreshControl = refreshControl
        } else {
            collectionFeeds.addSubview(refreshControl)
        }
        
        self.refreshControl.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
    }
    
    @objc func searchCloseTapped(_ sender:AnyObject){
        txtSearch.text = ""
        closeButton.isHidden = true
        setCategoryFilter()
        self.collectionFeeds.reloadData()
        self.collectionFeeds.collectionViewLayout.invalidateLayout()
    }
    
    @IBAction func onSearchCloseTap(_ sender: Any) {
        txtSearch.text = ""
        closeButton.isHidden = true
        setCategoryFilter()
        self.collectionFeeds.reloadData()
        self.collectionFeeds.collectionViewLayout.invalidateLayout()
    }
    
    func tapProfile(sender: UITapGestureRecognizer){
        if user!.type == "admin" {
            let vc = Utilities.viewController("UserListVC", onStoryboard: "Settings") as! UserListVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let vc = Utilities.viewController("EditProfileViewController", onStoryboard: "Settings") as! EditProfileViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (closeButton.isHidden == true){
            closeButton.isHidden = false
        }
        return true
    }
    
    @IBAction func searchBegin(_ sender: Any) {
        closeButton.isHidden = false
    }
    
    @IBAction func searchTextChanged(_ sender: UITextField) {
        var searchName:String?
        searchName = sender.text
        if (searchName != nil)
        {
            setCategoryFilter()
            self.collectionFeeds.reloadData()
            self.collectionFeeds.collectionViewLayout.invalidateLayout()
        }
    }
    
    @IBAction func searchEnd(_ sender: Any) {
        closeButton.isHidden = true
    }
    
    private func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.distanceFilter = 10
        locationManager.startUpdatingLocation()
    }

    func getFeeds() {
        FSProductManager.sharedInstance.getFeeds(
            completion: { (outFeeds) in
                if FSProductManager.sharedInstance.isCollecting == true {
                    return
                }
                DispatchQueue.main.async(execute: {
                    self.resultFeeds = outFeeds
                    self.setCategoryFilter()
                    self.arrangeData()

                    self.collectionFeeds.reloadData()
                    self.collectionFeeds.collectionViewLayout.invalidateLayout()

                    self.refreshControl.endRefreshing()
                })
        },
            failure: {(error) in
                self.showAlert(title: appName, message: error)
        })
    }
    
    func arrangeData() {
        self.searchFeeds.sort { (ref1, ref2) -> Bool in
            
            let data1 = ref1.value as? NSDictionary
            let data2 = ref2.value as? NSDictionary
            print(ref1.key)

            let outProduct1 = FSProduct(dataDictionary: data1!)
            let outProduct2 = FSProduct(dataDictionary: data2!)
            
            let isSurveyed1 = FSProductManager.sharedInstance.checkInMySurveys(outProduct1)
            let isSurveyed2 = FSProductManager.sharedInstance.checkInMySurveys(outProduct2)
            
            if isSurveyed1 == true && isSurveyed2 == true {
                
            }
            else if isSurveyed1 == false && isSurveyed2 == true {
                return true
            }
            else if isSurveyed1 == true && isSurveyed2 == false {
            }

            return false
        }
    }

    func searchFeedResults(_ searchContent: String) {
        self.searchFeeds = []
        for productRef in resultFeeds {
            var data = productRef.value as? NSDictionary
            let outProduct = FSProduct(dataDictionary: data!)
            if searchContent == "" {
                searchFeeds.append(productRef)
            }
            else if (outProduct.title.contains(searchContent) || outProduct.contentDescription.contains(searchContent)) {
                searchFeeds.append(productRef)
            }
        }
    }
    
    func setCategoryFilter() {
        self.searchFeeds = []
        var searchContent:String = ""
        for productRef in resultFeeds {
            var data = productRef.value as? NSDictionary
            let outProduct = FSProduct(dataDictionary: data!)
            
            if ((searchContent == "") || (outProduct.title.contains(searchContent) || outProduct.contentDescription.contains(searchContent))) {
                if (selectCat == outProduct.category || selectCat == "") {
                    if (selectSubCat == "All" || selectSubCat == "") {
                        searchFeeds.append(productRef)
                    }
                    else if (selectSubCat == outProduct.subcategory) {
                        searchFeeds.append(productRef)
                    }
                }
            }
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        getFeeds()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addTapped(_ sender: Any) {
        
        let vc = Utilities.viewController("AddNewFeedViewController", onStoryboard: "Feeds") as! AddNewFeedViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func filterTapped(_ sender: Any) {
        
        let vc = Utilities.viewController("FilterViewController", onStoryboard: "Feeds")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func menuTapped(_ sender: Any) {
        collectionCategory.isHidden = !collectionCategory.isHidden
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

extension FeedsViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        if collectionView == self.collectionFeeds {
            return CGSize(width: screenWidth, height: 114.0)
        }
        else {
            return CGSize(width: screenWidth*240.0/375.0, height: 49.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == self.collectionCategory{
            return 1
        }else if collectionView == self.collectionFeeds{
            return 0
        }
        else {
            return 30
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == self.collectionCategory{
            return 2
        }else{
            return 0
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionCategory{
            return categoryList.count
        }
        else {
            if searchFeeds == nil || searchFeeds == [] {
                return 0
            }
            else {
                return searchFeeds.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionCategory{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "catCell", for: indexPath) as! catCell
            cell.cellIndex = indexPath.row
            if (indexPath.row == categoryList.count) {
                cell.lblCat.text = "Other"
                cell.catImgName = "Other"
            }
            else {
                let catName = String(categoryList[indexPath.row].filter { !" &".contains($0) })
                cell.catImgName = catName
                cell.lblCat.text = categoryList[indexPath.row]
            }
            cell.delegate = self
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCell", for: indexPath) as! FeedCell
            cell.cellIndex = indexPath.row
            if (searchFeeds.count <= indexPath.row) {
                print("feed exception")
                return cell
            }
            
            cell.delegate = self
            cell.setupCell(ref: self.searchFeeds[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if (collectionView == collectionFeeds) {
            let vc = Utilities.viewController("FeedDetailViewController", onStoryboard: "Feeds") as! FeedDetailViewController
            vc.productRef = self.searchFeeds[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if (collectionView == collectionCategory) {
        }
    }
}

extension FeedsViewController : feedCellDelegate {
    
    func onRemoveFeed(index: Int) {
        
        let menuController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let removeAction = UIAlertAction(title: "Remove the game", style: .destructive) { (action) in
            // remove from my feed
            let cellRef:DataSnapshot? = self.searchFeeds[index]
            let cellData = cellRef?.value as? NSDictionary
            
            let cellProduct = FSProduct(dataDictionary: cellData!)
            FSProductManager.sharedInstance.removeProductByAdmin(cellProduct, completion: {
                self.collectionFeeds.reloadData()
                self.collectionFeeds.collectionViewLayout.invalidateLayout()
            }) { (error) in
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        menuController.addAction(cancelAction)
        menuController.addAction(removeAction)
        self.present(menuController, animated: true)
    }
}

extension FeedsViewController :catCellDelegate {
    
    func selectCat(index: Int) {
        
        if index == categoryList.count {
            selectCat = "Select"
        }
        else {
            selectCat = categoryList[index]
        }
        selectSubCat = ""
        setCategoryFilter()
        self.collectionFeeds.reloadData()
        self.collectionFeeds.collectionViewLayout.invalidateLayout()
    }
    
    func deselectCat() {
        self.selectCat = ""
        self.selectSubCat = ""
        self.setCategoryFilter()
        self.collectionFeeds.reloadData()
        self.collectionFeeds.collectionViewLayout.invalidateLayout()
    }
}

extension FeedsViewController :SubCatCellDelegate {
    
    func catClose() {
    }
}

extension FeedsViewController : CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        locationManager.stopUpdatingLocation()
        getCurrentLocation(userLocation: userLocation)
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    func getCurrentLocation(userLocation:CLLocation) {
        let geocoder = CLGeocoder()
        
        // Look up the location and pass it to the completion handler
        geocoder.reverseGeocodeLocation(userLocation,
                completionHandler: { (placemarks, error) in
                    if error == nil {
                        let userPlace = placemarks?[0]
                        FSUserManager.sharedInstance.updateLocation(userPlace!)
                    }
                    else {
                        // An error occurred during geocoding.
                        
                    }
        })
    }
}




