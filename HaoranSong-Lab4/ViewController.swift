//
//  ViewController.swift
//  HaoranSong-Lab4
//
//  Created by Haoran Song on 10/20/22.
//

import UIKit

class ViewController: UIViewController{
    
    struct APIResults:Decodable {
        let page: Int
        let total_results: Int
        let total_pages: Int
        let results: [Movie]
    }
    struct Movie: Decodable {
        let id: Int!
        let poster_path: String?
        let title: String
        let release_date: String?
        let vote_average: Double
        let overview: String
        let vote_count:Int!
        let genre_ids: [Int]
    }
    struct GenreBackData: Decodable {
        let genres: [Genre]
    }
    
    struct Genre: Decodable {
        let id: Int
        let name: String
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        return imageView
    }()
//
    var theData : APIResults?
    var theImageCache : [UIImage] = []
    var theGenre : GenreBackData?
    var genreDict: [Int: String] = [:]
    let apiKey = ""
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var appSubtitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Movies"
        searchBar.delegate = self
        setupCollectionView()
        addLoadingView()
        DispatchQueue.global(qos: .userInitiated).async {
            self.createDatabase()
            self.getDataFromTMDB(query: "")
            self.getGenre()
            self.cacheImages()
            
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.collectionView.reloadData()
            }
        }
    }
    
    private func createDatabase(){
        let database = SQLiteDatabase.sharedInstance
        database.createTable()
    }
    
    func addLoadingView(){
        let loadingView: LoadingView = LoadingView(frame: CGRect(x: view.frame.size.width/2-50, y: view.frame.size.height/2-50, width: 100, height: 100))

        loadingView.backgroundColor = UIColor(displayP3Red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 0.3)
        UIView.transition(with: view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            self.view.addSubview(loadingView)
        }, completion: nil)
    }
    
    func removeLoadingView(){
        for item in view.subviews {
            if item.isKind(of: LoadingView.self) {
                UIView.transition(with: view, duration: 1, options: [.transitionCrossDissolve], animations: {
                  item.removeFromSuperview()
                }, completion: nil)
            }
        }
    }
    
    func setupCollectionView(){
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "mycell")
    }
    
    func getGenre(){
        var url:URL?
        url = URL(string:"https://api.themoviedb.org/3/genre/movie/list?api_key=\(apiKey)")
        
        let data = try! Data(contentsOf: url!)
        theGenre = try! JSONDecoder().decode(GenreBackData.self,from:data)
        for i in (theGenre?.genres)!{
            genreDict[i.id] = i.name
        }
    }
    
    func getDataFromTMDB(query: String){
        var url:URL?
        
        var myQuery = query.removeSpecialCharacters().condensedWhitespace
        myQuery = myQuery.unicodeScalars
            .filter { !$0.properties.isEmojiPresentation }
            .reduce("") { $0 + String($1) }
        
        if(myQuery.count==0){
            url = URL(string:"https://api.themoviedb.org/3/movie/popular?api_key=\(apiKey)&language=en-US&page=1")
        }else{
            url = URL(string:"https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&language=en-US&query=\(myQuery)")
        }
        do{
            let data = try Data(contentsOf: url!)
            theData = try JSONDecoder().decode(APIResults.self,from:data)
        }catch{}

    }
    
    func cacheImages(){
        theImageCache = []
        for item in theData?.results ?? [] {
            if(item.poster_path==nil){
                theImageCache.append(UIImage(named: "empty")!)
            }else{
                let url = URL(string: "https://image.tmdb.org/t/p/original\( item.poster_path ?? "0")")
                do{
                    let data = try Data(contentsOf: url!)
                    let image = UIImage(data: data)
                    theImageCache.append(image!)
                }catch{
                    theImageCache = []
                }

            }
        }
    }

}

extension ViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        let query = searchBar.text
        addLoadingView()
        DispatchQueue.global(qos: .userInitiated).async {
            self.getDataFromTMDB(query: query ?? "")
            self.cacheImages()
            
            DispatchQueue.main.async {
                self.removeLoadingView()
                if(query==""){
                    self.appSubtitle.text = "Popular"
                    self.appSubtitle.font =  self.appSubtitle.font.withSize(35)
                }else{
                    self.appSubtitle.text = "Search Result"
                    self.appSubtitle.font =  self.appSubtitle.font.withSize(30)
                }
                self.collectionView.reloadData()
            }
        }
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return theImageCache.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mycell", for: indexPath)
        
        let imageview:UIImageView=UIImageView(frame: CGRect(x: 0, y: 0, width: (view.frame.size.width/3)-3, height: (view.frame.size.width/3*1.2)));
        imageview.image = theImageCache[indexPath.item]
        
        let title = UILabel(frame: CGRect(x: 0, y: 155, width: (view.frame.size.width/3)-3, height: (view.frame.size.width/3*0.15)))
        title.text = theData?.results[indexPath.item].title
        title.font = UIFont(name: "Futura", size: CGFloat(14))
        imageview.addSubview(title)
        
        let rate = UILabel(frame: CGRect(x: 0, y: 172, width: (view.frame.size.width/3)-3, height: (view.frame.size.width/3*0.15)))
        let vote = theData?.results[indexPath.item].vote_average ?? 0.0
        let rateString = "Vote Average: \(vote)"
        let mString = NSMutableAttributedString(string: rateString)
        if(vote>=7.5){
            mString.setAttributes(
                [NSAttributedString.Key.foregroundColor : UIColor(red: 1.00, green: 0.73, blue: 0.20, alpha: 1.00)],
                range: NSRange(location: 14, length: mString.string.count - 14)
            )
        }else if(vote<6){
            mString.setAttributes(
                [NSAttributedString.Key.foregroundColor : UIColor(red: 1.00, green: 0.20, blue: 0.20, alpha: 1.00)],
                range: NSRange(location: 14, length: mString.string.count - 14)
            )
        }else{
            mString.setAttributes(
                [NSAttributedString.Key.foregroundColor : UIColor(red: 0.36, green: 0.84, blue: 0.36, alpha: 1.00)],
                range: NSRange(location: 14, length: mString.string.count - 14)
            )
        }
        rate.attributedText = mString
        rate.font = UIFont(name: "Futura", size: CGFloat(12))
        imageview.addSubview(rate)
        cell.contentView.subviews.forEach {$0.removeFromSuperview()}
        UIView.transition(with: cell.contentView, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            cell.contentView.addSubview(imageview)
        }, completion: nil)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(
            width: (view.frame.size.width/3)-3,
            height: (view.frame.size.width/3*1.5)
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let detailedVC = DetailViewController()
        
        detailedVC.imageName = (theData?.results[indexPath.item].title)!
        detailedVC.image = theImageCache[indexPath.row]
        let listGenres = theData?.results[indexPath.item].genre_ids
        
        var genresString: String = ""
        for i in listGenres!{
            genresString += genreDict[i]! + ", "
        }
        if(genresString.count>0){
            genresString.remove(at: genresString.index(before: genresString.endIndex))
            genresString.remove(at: genresString.index(before: genresString.endIndex))
        }
        let releaseDate = theData?.results[indexPath.item].release_date
        let passInfo = releaseDate! + "\n" + genresString
        detailedVC.subtitle = passInfo
        detailedVC.overview = (theData?.results[indexPath.item].overview)!
        detailedVC.rating = (theData?.results[indexPath.item].vote_average)!
        detailedVC.id = (theData?.results[indexPath.item].id)!


        navigationController?.pushViewController(detailedVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let status = UserDefaults.standard.object(forKey: "Movie_\((theData?.results[indexPath.item].id)!)") == nil ? false: true
        
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil){ [self] _ in
            let open = UIAction(title: status == false ? "Like" : "Unlike", image: status == false ? UIImage(systemName: "heart") : UIImage(systemName: "heart.fill"), identifier: nil, discoverabilityTitle: nil, state: .off){ _ in
                
                if(status==false){
                    let imageData = self.theImageCache[indexPath.row].jpegData(compressionQuality: 1)
                    let imageBase64String = imageData?.base64EncodedString()
                    
                    let listGenres = self.theData?.results[indexPath.item].genre_ids
                    
                    var genresString: String = ""
                    for i in listGenres!{
                        genresString += self.genreDict[i]! + ", "
                    }
                    genresString.remove(at: genresString.index(before: genresString.endIndex))
                    genresString.remove(at: genresString.index(before: genresString.endIndex))
                    let releaseDate = self.theData?.results[indexPath.item].release_date
                    let passInfo = releaseDate! + "\n" + genresString
                    
                    let likedMovie = LikedMovie(poster: imageBase64String!, title: (self.theData?.results[indexPath.item].title)!, subtitle: passInfo, vote_average: (self.theData?.results[indexPath.item].vote_average)!, overview: (self.theData?.results[indexPath.item].overview)!,
                    id: (self.theData?.results[indexPath.item].id)!)
                    
                    let encoder = JSONEncoder()
                    let defaults = UserDefaults.standard
                    if let encoded = try? encoder.encode(likedMovie) {
                        defaults.set(encoded, forKey: "Movie_\(likedMovie.id!)")
                    }
                }else{
                    UserDefaults.standard.removeObject(forKey: "Movie_\((self.theData?.results[indexPath.item].id)!)")
                }

            }
            
            return UIMenu(title: (theData?.results[indexPath.item].title)! , image: nil, identifier: nil, options: UIMenu.Options.displayInline, children: [open])
        }
        
        return config
    }
    
}
// Reference:  https://stackoverflow.com/questions/56984247/swift-how-to-remove-special-character-without-remove-emoji-from-string
extension String {
    var condensedWhitespace: String {
        let components = self.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }

    func removeSpecialCharacters() -> String {
        let okayChars = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890 ")
        return String(self.unicodeScalars.filter { okayChars.contains($0) || $0.properties.isEmoji })
    }
}

