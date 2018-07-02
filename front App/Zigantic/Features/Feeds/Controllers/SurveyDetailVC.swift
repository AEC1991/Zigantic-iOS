//
//  SurveyDetailVC.swift
//  Zigantic
//
//  Created by iOS Developer on 4/3/18.
//  Copyright © 2018 Chirag Ganatra. All rights reserved.
//

import UIKit

class SurveyDetailVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnSubmit: FSLoadingButton!    
    @IBOutlet weak var questionCollection: UICollectionView!
    
    var surveyId:String?
    var survey:FSSurvey!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        FSSurveyManager.sharedInstance.getById(uid: surveyId!, completion: { (outSurvey) in
            self.survey = outSurvey
            self.questionCollection.reloadData()
            FSUserManager.sharedInstance.getById(uid: outSurvey.userId, completion: { (outUser) in
                self.lblTitle.text = outUser.username + "'s Survey"
            }, failure: { (error) in
            })
        }) { (error) in
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setQuestion() {
        var surQuestions:[String] = []
        var surAnswers:[String] = []
        
        for index in 0...survey.answers.count - 1 {
            let indexPath = IndexPath(item: index, section: 0)
            let cell = questionCollection!.cellForItem(at: indexPath) as! QuestionCell
            let question = cell.lblQuestion.text as? String
            let answer = cell.txtAnswer.text as? String
            
            if question != nil && answer != nil {
                surQuestions.append(question!)
                surAnswers.append(answer!)
            }
        }
        survey.questionStruct = Dictionary(uniqueKeysWithValues: zip(surQuestions, surAnswers))
        FSSurveyManager.sharedInstance.survey = self.survey
    }
    
    @IBAction func onUpdate(_ sender: Any) {
        
        setQuestion()
        self.btnSubmit.showLoading()
        FSSurveyManager.sharedInstance.submitSurvey(
            completion: { (survey) in
                self.btnSubmit.hideLoading()
                self.showAlert(title: appName, message: "Successfully updated this survey!")
        },
            failure: {(error) in
                self.btnSubmit.hideLoading()
        })
    }
    
    @IBAction func onRemove(_ sender: Any) {
        let menuController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let removeAction = UIAlertAction(title: "Remove this survey", style: .destructive) { (action) in
            // remove survey
            FSSurveyManager.sharedInstance.removeSurveyByAdmin(self.survey, completion: {
                self.dismiss(animated: true, completion: nil)
            }, failure: { (error) in
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        menuController.addAction(cancelAction)
        menuController.addAction(removeAction)
        self.present(menuController, animated: true)
    }

    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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

extension SurveyDetailVC : UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.survey == nil {
            return 1
        }
        else {
            return survey.questions.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuestionCell", for: indexPath) as! QuestionCell
        let question:String = "Game Application Question " + String(indexPath.row + 1)
        if self.survey == nil {
            return cell
        }
        cell.lblQuestion.text = self.survey.questions[indexPath.row]
        cell.txtAnswer.text = self.survey?.answers[indexPath.row]
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
