//
//  DatabaseCommand.swift
//  HaoranSong-Lab4
//
//  Created by Haoran Song on 10/26/22.
//

import Foundation
import SQLite

class DatabaseCommand {
    
    static var table = Table("reviews")
    
    // Expressions
    static let id = Expression<Int>("id")
    static let userName = Expression<String>("userName")
    static let movieId = Expression<Int>("movieId")
    static let movieName = Expression<String>("movieName")
    static let review = Expression<String>("review")
    static let userAvar = Expression<String>("userAvar")
    
    // Creating Table
    static func createTable() {
        guard let database = SQLiteDatabase.sharedInstance.database else {
            print("Datastore connection error")
            return
        }
        
        do {
            try database.run(table.create(ifNotExists: true) { table in
                table.column(id, primaryKey: .autoincrement)
                table.column(userName)
                table.column(movieId)
                table.column(movieName)
                table.column(review)
                table.column(userAvar)
            })
        } catch {
            print("Table already exists: \(error)")
        }
    }
    
    // Inserting Row
    static func insertRow(_ reviewValues: Review) -> Bool? {
        guard let database = SQLiteDatabase.sharedInstance.database else {
            print("Datastore connection error")
            return nil
        }
        
        do {
            try database.run(table.insert(userName <- reviewValues.userName, movieId <- reviewValues.movieId, movieName <- reviewValues.movieName, review <- reviewValues.review, userAvar <- reviewValues.userAvar))
            return true
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("Insert row failed: \(message), in \(String(describing: statement))")
            return false
        } catch let error {
            print("Insertion failed: \(error)")
            return false
        }
    }
    // Present Rows
    static func presentRows(myMovieId: Int) -> [Review]? {
        guard let database = SQLiteDatabase.sharedInstance.database else {
            print("Datastore connection error")
            return nil
        }
        
        var reviewArray = [Review]()
        
        table = table.order(id.desc)
        
        do {
            for getReview in try database.prepare(table) {
                if(getReview[movieId]==myMovieId){
                    let userNameValue = getReview[userName]
                    let movieIdValue = getReview[movieId]
                    let movieNameValue = getReview[movieName]
                    let reviewValue = getReview[review]
                    let avarValue = getReview[userAvar]
                    
                    let myReview = Review(userName: userNameValue, userAvar: avarValue, movieId: movieIdValue, movieName: movieNameValue, review: reviewValue)

                    reviewArray.append(myReview)
                }

            }
        } catch {
            print("Present row error: \(error)")
        }
        return reviewArray
    }
}

