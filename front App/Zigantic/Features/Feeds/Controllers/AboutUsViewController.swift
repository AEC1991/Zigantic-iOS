//
//  AboutUsViewController.swift
//  Zigantic
//
//  Created by iOS Developer on 4/1/18.
//  Copyright © 2018 Chirag Ganatra. All rights reserved.
//

import UIKit

class AboutUsViewController: UIViewController {
    
    @IBOutlet weak var teamCollection: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension AboutUsViewController:UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return teamList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TeamCell", for: indexPath) as! TeamCell
        switch indexPath.row {
        case 0:
            cell.avatarCell.image = UIImage(named:"vignav")
            break
        case 1:
            cell.avatarCell.image = UIImage(named:"rishab")
            break
        case 2:
            cell.avatarCell.image = UIImage(named:"tej")
            break
        default:
            break
        }
        
        cell.lblName.text = teamList[indexPath.row]

        return cell
    }    
}




