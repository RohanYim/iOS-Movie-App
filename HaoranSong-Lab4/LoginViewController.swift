//
//  LoginViewController.swift
//  HaoranSong-Lab4
//
//  Created by Haoran Song on 10/24/22.
//

import UIKit
import WebKit

class LoginViewController: UIViewController {
    var webView: WKWebView!
    var url: String = ""
    var apiKey = ""
    
    struct theSession: Codable {
        var success: Bool
        var session_id: String
    }
    var sessionData: theSession?
    var session: String = ""
    
    struct theUser: Codable {
        var avatar: theAvatar?
        var username: String
        var id: Int
    }
    
    struct userWithoutAvatar: Codable {
        var username: String
        var id: Int
    }
    
    struct theAvatar: Codable {
        var tmdb: theTmdb?
    }
    struct theTmdb: Codable {
        var avatar_path: String = ""
    }
    var userData: theUser?
    var userWithoutAvatarData: userWithoutAvatar?
    var userAvatar: String = ""
    var userName: String = ""
    var userImage: UIImage?
    var userId: Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myURL = URL(string: url)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
}

extension LoginViewController: WKUIDelegate, WKNavigationDelegate {

    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
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

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        guard let url = navigationResponse.response.url else {
            decisionHandler(.allow)
            return
        }
        if url.absoluteString.contains("/allow") {
            
            let headers = (navigationResponse.response as! HTTPURLResponse).allHeaderFields
            let sessionUrl = URL(string:headers["authentication-callback"] as! String)
            let data = try! Data(contentsOf: sessionUrl!)
            sessionData = try! JSONDecoder().decode(theSession.self,from:data)
            session = sessionData!.session_id
            
            let userUrl = URL(string:"https://api.themoviedb.org/3/account?api_key=\(apiKey)&session_id=\(session)")

            let uData = try! Data(contentsOf: userUrl!)
            let defaults = UserDefaults.standard
            do{
                userData = try JSONDecoder().decode(theUser.self,from:uData)
                userAvatar = (userData!.avatar?.tmdb?.avatar_path) ?? ""
                userName = userData?.username ?? ""
                userId = userData?.id

                let image_path = "https://image.tmdb.org/t/p/original/\(userAvatar)"

                if(userAvatar==""){
                    userImage = UIImage(named: "empty")
                }else{
                    let url = URL(string: image_path)
                    let data = try? Data(contentsOf: url!)
                    userImage = UIImage(data: data!)
                }

                let imageData = userImage!.jpegData(compressionQuality: 1)
                let imageBase64String = imageData?.base64EncodedString()

                defaults.set(userName, forKey: "myName")
                defaults.set(imageBase64String, forKey: "myAvatar")
                defaults.set(userId, forKey: "myId")
            } catch{
                userWithoutAvatarData = try! JSONDecoder().decode(userWithoutAvatar.self,from:uData)
                userName = userWithoutAvatarData?.username ?? ""
                userId = userWithoutAvatarData?.id
                defaults.removeObject(forKey: "myAvatar")
                defaults.set(userName, forKey: "myName")
                defaults.set(userId, forKey: "myId")
                
            }
     
            let favoriteUrl = URL(string:"https://api.themoviedb.org/3/account/%7Baccount_id%7D/favorite?api_key=\(apiKey)&session_id=\(session)")
            guard let requestUrl = favoriteUrl else { fatalError() }
            for i in UserDefaults.standard.dictionaryRepresentation().keys{
                if i.contains("Movie_") {
                    var request = URLRequest(url: requestUrl)
                    request.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
                    request.httpMethod = "POST"
                    let id = NSString(string:i)
                    let parameters: [String: Any] = [
                        "media_type": "movie",
                        "media_id": Int(id.components(separatedBy: "_")[1])!,
                        "favorite": true
                    ]
                    let bodyData = try? JSONSerialization.data(
                        withJSONObject: parameters,
                        options: []
                    )
                    request.httpBody = bodyData
                    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                            if let error = error {
                                print("Error took place \(error)")
                                return
                            }
                            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                                print("Response data string:\n \(dataString)")
                            }
                    }
                    task.resume()
                }
            }
            _ = self.navigationController?.popViewController(animated: true)
            decisionHandler(.cancel)
        }
        else {
            decisionHandler(.allow)
        }
        
    }
}
