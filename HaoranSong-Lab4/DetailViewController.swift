//
//  DetailViewController.swift
//  HaoranSong-Lab4
//
//  Created by Haoran Song on 10/22/22.
//

import UIKit

class DetailViewController: UIViewController {
    
    var image: UIImage = UIImage(named: "empty")!
    var imageName: String = "namePlaceHolder"
    var subtitle: String = "subtitlePlaceHolder"
    var overview: String = "overVIewPlaceHolder"
    var rating: Double = 0.0
    var id: Int = 0
    let defaults = UserDefaults.standard
    
    let favoriteButton = UIButton()
    let addReviewButton = UIButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(red: 0.92, green: 0.92, blue: 0.88, alpha: 1.00)
        
        let theImageFrame = CGRect(x: 20, y: 104, width: 150, height: 225)
        let imageView = UIImageView(frame:theImageFrame)
        imageView.image = image
        view.addSubview(imageView)
        
        let textView = UILabel()
        textView.text = imageName
        textView.font = UIFont.boldSystemFont(ofSize: 16)
        textView.numberOfLines = 0
        textView.textAlignment = .left
        textView.lineBreakMode = NSLineBreakMode.byWordWrapping
        let titleSize = textView.sizeThatFits(CGSize(width: 195, height: CGFloat(MAXFLOAT)))
        let titleFrame = CGRect(x: 195, y: 104, width: 195, height: titleSize.height)
        textView.frame = titleFrame
        view.addSubview(textView)
        
        let subtitleView = UILabel()
        subtitleView.text = subtitle
        subtitleView.font = subtitleView.font.withSize(12)
        subtitleView.numberOfLines = 0
        subtitleView.textAlignment = .left
        subtitleView.lineBreakMode = NSLineBreakMode.byWordWrapping
        let subtitleSize = subtitleView.sizeThatFits(CGSize(width: 195, height: CGFloat(MAXFLOAT)))
        let subtitleFrame = CGRect(x: 195, y: 170, width: 195, height: subtitleSize.height)
        subtitleView.frame = subtitleFrame
        view.addSubview(subtitleView)
        
        let overviewTitle = UILabel()
        overviewTitle.text = "Overview"
        overviewTitle.font = UIFont.boldSystemFont(ofSize: 20)
        let overviewTitleFrame = CGRect(x: 20, y: 396, width: 90, height: 21)
        overviewTitle.frame = overviewTitleFrame
        view.addSubview(overviewTitle)
        
        let overviewView = UILabel()
        overviewView.text = overview
        overviewView.font = overviewView.font.withSize(14)
        overviewView.numberOfLines = 0
        overviewView.textAlignment = .left
        overviewView.lineBreakMode = NSLineBreakMode.byWordWrapping
        let overviewSize = overviewView.sizeThatFits(CGSize(width: 365, height: CGFloat(MAXFLOAT)))
        let overviewFrame = CGRect(x: 20, y: 433, width: 365, height: overviewSize.height)
        overviewView.frame = overviewFrame
        view.addSubview(overviewView)
    
        
        if(UserDefaults.standard.object(forKey: "Movie_\(id)") != nil){
            favoriteButton.setTitle(" Liked", for: .normal)
            favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }else{
            favoriteButton.setTitle(" Like", for: .normal)
            favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        favoriteButton.setTitleColor(.black, for: .normal)
        favoriteButton.tintColor = .red
        favoriteButton.backgroundColor = .white
        let favoriteButtonFrame = CGRect(x: 195, y: 305, width: 93, height: 31)
        favoriteButton.frame = favoriteButtonFrame
        favoriteButton.layer.cornerRadius = 10
        favoriteButton.layer.masksToBounds = true
        favoriteButton.addTarget(self, action:#selector(self.likeClicked), for: .touchUpInside)

        view.addSubview(favoriteButton)
        
        let rateStar = UILabel(frame: CGRect(x: 195, y: 266, width: 199, height: 21))
        rateStar.attributedText = NSMutableAttributedString().starWithRating(rating: Float(round(rating)), outOfTotal: 10, withFontSize: 12.0)
        view.addSubview(rateStar)
        
        let rate = UILabel(frame: CGRect(x: 195, y: 206, width: 99, height: 60))
        rate.text = String(rating)
        rate.font = UIFont.boldSystemFont(ofSize: 50)
        view.addSubview(rate)
        
        let reviewTitle = UILabel()
        
        
        let reviewString = "Reviews \u{276F}"
        let mString = NSMutableAttributedString(string: reviewString)
        mString.setAttributes(
            [NSAttributedString.Key.foregroundColor : UIColor(red: 0.50, green: 0.50, blue: 0.50, alpha: 1.00)],
            range: NSRange(location: 8, length: mString.string.count - 8)
        )
        
        reviewTitle.attributedText = mString
        reviewTitle.font = UIFont.boldSystemFont(ofSize: 20)
        let reviewTitleFrame = CGRect(x: 20, y: 600, width: 130, height: 21)
        reviewTitle.frame = reviewTitleFrame
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.reviewClicked))
        reviewTitle.isUserInteractionEnabled = true
        reviewTitle.addGestureRecognizer(tap)
//        reviewTitle.addTarget(self, action:#selector(self.likeClicked), for: .touchUpInside)
        view.addSubview(reviewTitle)
        
        
        addReviewButton.setImage(UIImage(systemName: "highlighter"), for: .normal)
        addReviewButton.tintColor = UIColor(red: 0.50, green: 0.50, blue: 0.50, alpha: 1.00)
        addReviewButton.backgroundColor = .clear
        let addReviewButtonFrame = CGRect(x: 295, y: 600, width: 93, height: 31)
        addReviewButton.frame = addReviewButtonFrame
        addReviewButton.addTarget(self, action:#selector(self.addReviewClicked), for: .touchUpInside)
        view.addSubview(addReviewButton)
        
        
        let tmdbView = UILabel(frame: CGRect(x: 20, y: 730, width: 200, height: 21))
        tmdbView.text = "@All data retrived from TMDb"
        tmdbView.font = UIFont.italicSystemFont(ofSize: 10)
        view.addSubview(tmdbView)

    }
    
    @objc func likeClicked(){
        if(defaults.object(forKey: "Movie_\(id)") == nil){
            let imageData = image.jpegData(compressionQuality: 1)
            let imageBase64String = imageData?.base64EncodedString()
            
            let likedMovie = LikedMovie(poster: imageBase64String!, title: imageName, subtitle: subtitle, vote_average: rating, overview: overview, id: id)
            
            let encoder = JSONEncoder()
            let defaults = UserDefaults.standard
            if let encoded = try? encoder.encode(likedMovie) {
                defaults.set(encoded, forKey: "Movie_\(likedMovie.id!)")
            }
            
            favoriteButton.setTitle(" Liked", for: .normal)
            favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }else{
            defaults.removeObject(forKey: "Movie_\(id)")
            favoriteButton.setTitle(" Like", for: .normal)
            favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }
    
    @objc func reviewClicked(){
        let reviewVC = ReviewViewController()
        reviewVC.movieTitle = imageName
        reviewVC.movieId = id
        navigationController?.pushViewController(reviewVC, animated: true)
        
    }
    
    @objc func addReviewClicked(){
        let addReviewVC = AddReviewViewController()
        addReviewVC.movieTitle = imageName
        addReviewVC.movieId = id
        navigationController?.pushViewController(addReviewVC, animated: true)
    }
    
    
}


// Reference: https://stackoverflow.com/questions/16100378/is-there-any-controls-available-for-star-rating
extension NSMutableAttributedString{

    func starWithRating(rating:Float, outOfTotal totalNumberOfStars:NSInteger, withFontSize size:CGFloat) ->NSAttributedString{


        let currentFont = UIFont(name: "Futura", size: size)!

        let activeStarFormat = [ NSAttributedString.Key.font:currentFont, NSAttributedString.Key.foregroundColor: UIColor(red: 1.00, green: 0.64, blue: 0.10, alpha: 1.00)];

        let inactiveStarFormat = [ NSAttributedString.Key.font:currentFont, NSAttributedString.Key.foregroundColor: UIColor.lightGray];

        let starString = NSMutableAttributedString()

        for i in 0...totalNumberOfStars-1{

            if(rating >= Float(i+1)){

                starString.append(NSAttributedString(string: "\u{2605}", attributes: activeStarFormat))
            }else{
                starString.append(NSAttributedString(string: "\u{2605}", attributes: inactiveStarFormat))
            }
        }

        return starString
    }
}


