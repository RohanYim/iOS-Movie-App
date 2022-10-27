//
//  LikedData.swift
//  HaoranSong-Lab4
//
//  Created by Haoran Song on 10/22/22.
//

import UIKit

class LikedData: NSObject, NSCoding {
//    var poster: UIImage?
    var title: String
    var subtitle: String?
//    var vote_average: Double
//    var overview: String
     
    //构造方法
    required init(title:String="", subtitle:String="") {
        self.title = title
        self.subtitle = subtitle
    }
     
    //从object解析回来
    required init(coder decoder: NSCoder) {
        self.title = decoder.decodeObject(forKey: "Title") as? String ?? ""
        self.subtitle = decoder.decodeObject(forKey: "Subtitle") as? String ?? ""
    }
     
    //编码成object
    func encode(with coder: NSCoder) {
        coder.encode(title, forKey:"Title")
        coder.encode(subtitle, forKey:"Subtitle")
    }
    
    
}
