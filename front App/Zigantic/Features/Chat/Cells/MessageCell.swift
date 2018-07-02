//
//  MessageCell.swift
//  Bityo
//
//  Created by iOS Developer on 1/31/18.
//  Copyright © 2018 Chirag Ganatra. All rights reserved.
//

import UIKit

protocol MessageCellDelegate {
    func acceptOffer(_ index:Int)
    func rejectOffer(_ index:Int)
    func locationTapped(_ index:Int)
    func offerTapped(_ index:Int)

}

class MessageCell: UITableViewCell {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var lblMessage : UILabel!
    @IBOutlet weak var lblTime : UILabel!
    @IBOutlet weak var lblView: UIView!
    @IBOutlet weak var sentLocationImg: FSImageView!
    @IBOutlet weak var recvLocationImg: FSImageView!
    @IBOutlet weak var pinImgView: UIImageView!
    
    @IBOutlet weak var offerView: UIView!
    @IBOutlet weak var lblAcceptStatus: UILabel!
    @IBOutlet weak var lblOfferTime : UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnReject: UIButton!
    @IBOutlet weak var btnCheckOut: UIButton!
    
    @IBOutlet weak var offerSentView: UIView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblSentPrice: UILabel!
    
    @IBOutlet weak var statusTopConstraint: NSLayoutConstraint!

    var delegate: MessageCellDelegate?
    var cellIndex:Int?
    
    func clearCellData()  {
        self.lblMessage.text = nil
        self.lblMessage.isHidden = false
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCellIndex(index: Int) {
        cellIndex = index
        let tapSendLocationGesture = UITapGestureRecognizer(target: self, action: #selector(sendTapped))
        let tapRecvLocationGesture = UITapGestureRecognizer(target: self, action: #selector(recvTapped))
        let offerTapGesture = UITapGestureRecognizer(target: self, action: #selector(offerTapped))

        self.recvLocationImg?.addGestureRecognizer(tapRecvLocationGesture)
        self.sentLocationImg?.addGestureRecognizer(tapSendLocationGesture)
        self.offerView?.addGestureRecognizer(offerTapGesture)
        self.offerSentView?.addGestureRecognizer(offerTapGesture)
    }
    
    @objc func sendTapped(_ sender: AnyObject) {
        delegate?.locationTapped(cellIndex!)
    }
    
    @objc func recvTapped(_ sender: AnyObject) {
        delegate?.locationTapped(cellIndex!)
    }
    
    @objc func offerTapped(_ sender: AnyObject) {
        delegate?.offerTapped(cellIndex!)
    }

    @IBAction func acceptOffer(_ sender: Any) {
        print("accept offer")
        delegate?.acceptOffer(cellIndex!)
    }
    
    @IBAction func rejectOffer(_ sender: Any) {
        print("reject offer")
        delegate?.rejectOffer(cellIndex!)
    }
    
    @IBAction func checkOut(_ sender: Any) {
        delegate?.offerTapped(cellIndex!)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
