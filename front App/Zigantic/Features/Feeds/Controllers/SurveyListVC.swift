//
//  SurveyListVC.swift
//  Zigantic
//
//  Created by iOS Developer on 4/3/18.
//  Copyright © 2018 Chirag Ganatra. All rights reserved.
//

import UIKit

class SurveyListVC: UIViewController {
    
    @IBOutlet weak var surveyCollection: UICollectionView!
    var product:FSProduct?
    var inProduct:FSProduct?
    var surveyId:String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        FSProductManager.sharedInstance.getById(uid: (product?.uid)!, completion: { (outProduct) in
            self.inProduct = outProduct
            self.surveyCollection.reloadData()
        }) { (error) in
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let surveyDetail = segue.destination as? SurveyDetailVC {
            surveyDetail.surveyId = self.surveyId
        }
    }
}

extension SurveyListVC : UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if inProduct == nil {
            return 1
        }
        return (inProduct?.surveys.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SurveyCell", for: indexPath) as! SurveyCell
        if inProduct == nil {
            return cell
        }
        cell.setupCell(surveyId: (inProduct?.surveys[indexPath.row])!)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.surveyId = inProduct?.surveys[indexPath.row]
        self.performSegue(withIdentifier: "show.detail", sender: nil)
    }
}


