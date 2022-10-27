//
//  AddReviewViewController.swift
//  HaoranSong-Lab4
//
//  Created by Haoran Song on 10/26/22.
//

import UIKit

class AddReviewViewController: UIViewController {

    var movieTitle: String = "namePlaceHolder"
    var movieId: Int?
    let writeReview = UITextView()
    let submitBtn = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        let textView = UILabel()
        textView.text = movieTitle
        textView.font = UIFont.boldSystemFont(ofSize: 25)
        textView.numberOfLines = 0
        textView.textAlignment = .left
        textView.lineBreakMode = NSLineBreakMode.byWordWrapping
        let textViewSize = textView.sizeThatFits(CGSize(width: 358, height: CGFloat(MAXFLOAT)))
        let titleFrame = CGRect(x: 16, y: 100, width: 358, height: textViewSize.height)
        textView.frame = titleFrame
        view.addSubview(textView)
        
        writeReview.layer.borderWidth = 1
        writeReview.layer.borderColor = UIColor(red: 0.00, green: 0.42, blue: 0.46, alpha: 1.00).cgColor
        writeReview.layer.cornerRadius = 4
        writeReview.font = UIFont.systemFont(ofSize: 15)
        let writeReviewFrame = CGRect(x: 16, y: 175, width: 358, height: 200)
        writeReview.frame = writeReviewFrame
        view.addSubview(writeReview)
        
        submitBtn.setTitle("Submit", for: .normal)
        submitBtn.backgroundColor = UIColor(red: 0.00, green: 0.42, blue: 0.46, alpha: 1.00)
        let submitBtnFrame = CGRect(x: 277, y: 425, width: 93, height: 31)
        submitBtn.layer.cornerRadius = 10
        submitBtn.layer.masksToBounds = true
        submitBtn.frame = submitBtnFrame
        submitBtn.addTarget(self, action:#selector(self.submitClicked), for: .touchUpInside)
        view.addSubview(submitBtn)
        
    }
    
    @objc func submitClicked(){
        let userName = UserDefaults.standard.string(forKey: "myName")
        if(userName==nil){
            alert(title: "Login Needed", message: "Please connect to TMDb before adding reviews!")
        }else{
            if(writeReview.text==""){
                alert(title: "Review Empty", message: "Please add reviews before you submit!")
            }else{
                let movieId = movieId
                let movieName = movieTitle
                let review = writeReview.text
                let userAvar = UserDefaults.standard.string(forKey: "myAvatar")
                
                let myReview = Review(userName: userName!, userAvar: userAvar!, movieId: movieId!, movieName: movieName, review: review!)
                
                let addToDatabase = DatabaseCommand.insertRow(myReview)
                
                if addToDatabase == true {
                    navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    func alert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

}
