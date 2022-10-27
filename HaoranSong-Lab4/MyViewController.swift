//
//  MyViewController.swift
//  HaoranSong-Lab4
//
//  Created by Haoran Song on 10/23/22.
//

import UIKit

class MyViewController: UIViewController {

    struct Movie: Codable {
        var id: Int
        var poster: String
        var title: String
        var subtitle: String?
        var vote_average: Double
        var overview: String
    }
    struct theToken: Codable {
        var success: Bool
        var expires_at: String
        var request_token: String
    }
    var tokenData: theToken?
    var token: String = ""
    
    var likedList: [Movie] = []
    let defaults = UserDefaults.standard
    var myUserName = "Guest"
    var myAvatar: UIImage?
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var userBack: UIView!
    @IBOutlet weak var connectBtn: UIButton!
    @IBAction func connectBtnClicked(_ sender: Any) {
        var url:URL?
        url = URL(string:"https://api.themoviedb.org/3/authentication/token/new?api_key=d766a2eea4ccdbb5593aea0eafa7fb55")
    
        let data = try! Data(contentsOf: url!)
        tokenData = try! JSONDecoder().decode(theToken.self,from:data)
        token = tokenData!.request_token
        
        let urlString = "https://www.themoviedb.org/authenticate/\(token)"
        
        let loginVC = LoginViewController()
        loginVC.url = urlString
        navigationController?.pushViewController(loginVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUserAvatar()
        setupTableView()
        userBack.backgroundColor = UIColor(red: 0.92, green: 0.92, blue: 0.88, alpha: 1.00)
    }
    override func viewWillAppear(_ animated: Bool) {
        var tempList: [Movie] = []
        for i in UserDefaults.standard.dictionaryRepresentation().keys{
            if i.contains("Movie_") {
                if let temp = defaults.object(forKey: i) as? Data {
                    let decoder = JSONDecoder()
                    if let loadedTemp = try? decoder.decode(Movie.self, from: temp) {
                        tempList.append(loadedTemp)
                    }
                }
            }
        }
        likedList = tempList.sorted { (lhs, rhs) in
            return lhs.id > rhs.id
        }
        myTableView.reloadData()
        setupUserAvatar()
        if(UserDefaults.standard.string(forKey: "myName")==nil){
        }else{
            connectBtn.setTitle("Update Profile", for: .normal)
        }
            
    }
    
    func setupTableView() {
        myTableView.dataSource = self
        myTableView.delegate = self
        
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    func setupUserAvatar(){
        let avatarInDefaults = UserDefaults.standard.string(forKey: "myAvatar")
        if(avatarInDefaults==nil){
            userAvatar.image = myAvatar
        }else{
            let newImageData = Data(base64Encoded: avatarInDefaults!)
            let newImage = UIImage(data: newImageData!)
            userAvatar.image = newImage
        }
        userAvatar.layer.cornerRadius = (userAvatar.frame.size.width)/2
        userAvatar.layer.masksToBounds = true
        userAvatar.layer.borderWidth = 2;
        userAvatar.layer.borderColor = UIColor.white.cgColor
        userName.text = UserDefaults.standard.string(forKey: "myName")
    }
    
    
}

extension MyViewController: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likedList.count+1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        if(indexPath.item==0){
            cell.textLabel!.text = "@Movie data retrieved from TMDb"
            cell.textLabel!.font =  UIFont.italicSystemFont(ofSize: 12)
            cell.isUserInteractionEnabled = false
        }else{
            cell.textLabel!.text = likedList[indexPath.item-1].title
            cell.textLabel!.font = UIFont.boldSystemFont(ofSize: 18.0)
            
            let tempString = likedList[indexPath.item-1].subtitle
            let reStr = tempString!.replacingOccurrences(of: "\n", with: "/ ")
            cell.detailTextLabel?.text = reStr
            
            let newImageData = Data(base64Encoded: likedList[indexPath.item-1].poster)
            let newImage = UIImage(data: newImageData!)
            cell.imageView?.image = newImage
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailedVC = DetailViewController()
        detailedVC.imageName = likedList[indexPath.item-1].title
        let newImageData = Data(base64Encoded: likedList[indexPath.item-1].poster)
        let newImage = UIImage(data: newImageData!)
        detailedVC.image = newImage!
        detailedVC.subtitle = likedList[indexPath.item-1].subtitle!
        detailedVC.overview = likedList[indexPath.item-1].overview
        detailedVC.rating = likedList[indexPath.item-1].vote_average
        detailedVC.id = likedList[indexPath.item-1].id
        navigationController!.pushViewController(detailedVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if(indexPath.item==0){
            return UITableViewCell.EditingStyle.none
        }else{
            return UITableViewCell.EditingStyle.delete
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            if tableView.numberOfRows(inSection: indexPath.section) == 1{}else{
                if(indexPath.item==0){}else{
                    let key = "Movie_\(likedList[indexPath.item-1].id)"
                    likedList.remove(at: indexPath.item-1)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    defaults.removeObject(forKey: key)
                }

            }

        }
    }


}
