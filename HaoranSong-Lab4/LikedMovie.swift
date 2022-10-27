//
//  LikedMovie.swift
//  HaoranSong-Lab4
//
//  Created by Haoran Song on 10/27/22.
//

import Foundation

struct LikedMovie: Codable {
    var poster: String
    var title: String
    var subtitle: String?
    var vote_average: Double
    var overview: String
    var id: Int!
}
