//
//  ReviewViewController.swift
//  HaoranSong-Lab4
//
//  Created by Haoran Song on 10/26/22.
//

import UIKit

class ReviewViewController: UIViewController {

    var movieTitle: String = "namePlaceHolder"
    var movieId: Int?
    let reviews = UITableView()
    var reviewArray: [Review] = []
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
        
        let reviewFrame = CGRect(x: 16, y: 142, width: 358, height: 668)
        reviews.frame = reviewFrame
//        reviews.backgroundColor = .black
        view.addSubview(reviews)
        setupTableView()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.getReviewData()
            
            DispatchQueue.main.async {
                self.reviews.reloadData()
            }
        }
        
    }
    
    func setupTableView() {
        reviews.dataSource = self
        reviews.delegate = self
        reviews.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func getReviewData(){
        reviewArray = DatabaseCommand.presentRows(myMovieId: movieId!)!
    }
}

extension ReviewViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.layer.cornerRadius = 4
        cell.clipsToBounds = true
        cell.textLabel!.text = reviewArray[indexPath.item].userName
        cell.textLabel!.font = UIFont.systemFont(ofSize: 10)
        cell.textLabel?.textColor = UIColor.gray
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = reviewArray[indexPath.item].review
        cell.detailTextLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        cell.detailTextLabel?.textColor = UIColor.black
        let newImageData = Data(base64Encoded: reviewArray[indexPath.item].userAvar)
        
        var newImage = UIImage(data: newImageData!)
        if(newImageData?.count==0){
            newImage = UIImage(named: "black")
        }

        cell.imageView?.image = newImage
        cell.isUserInteractionEnabled = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }

}
