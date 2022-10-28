What's new

· Save movie details to local:
Instead of just save a movie title to local, the app saved all the data shows in the movie detailed page to local, user can access the whole detail page without any Internet connection.

How do we implement it?
1. Create a new data struct called LikedMovie which included all the detailed page data.
2. UIImage is not codable, we use "image.jpegData(compressionQuality: 1)" to compress image data and use "imageData?.base64EncodedString()" to encode it to string.
3. Save LikedMovie data to user defaults
4. Get LikedMovie data from user defaults when "My" view is shown, including decode image data using "Data(base64Encoded: imagedata)"


· Connect to TMDb
You can connect your TMDb account to this app by clicking the button "Connect to TMDb"(or "Update Profile") on the "My" tab view. By doing this, you will be able to get your TMDb avatar and username. In addition, this function will also sync your favorite movies to TMDb, which means all the movies you liked in this app will also be added to your favorite list on your TMDb account. 

How do we implement it?
1. By click the connect button, it will lead you to the TMDb authentication page.
2. Create a request token using /authentication/token/new API
3. Ask the user for permission, if apporved, we will get a Authentication-Callback header.
4. User linked provided in the Authentication-Callback to get a session_id.
5. Request get /account API with session_id to get the user's avatar and username.
6. Get all the liked movies in the user default, use POST /account/{account_id}/favorite API to mark all the liked movies as favorited on the TMDb account.

· Reviews
By clicking the review button on the detailed page, users can check reviews added by all the users on this app, and after logging in, users are allowed to add reviews to the movie by clicking the button with "pen" icon on the detailed page.

How do we implement it?
1. Build a database using SQLite3, create a new "Review" struct with username, useravatar, movieid, moviename and review in it and build a table based on "Review".
2. By clicking "submit" on the add review page, simpily add a row to the table.
3. Select the movie reviews using movie id from the database and post them to the page using a table view.

· User Friendly Design
1. More details are shown on the detailed page: Title, Scores, genres, release date, overview...
2. You can like and dislike using the Context Menu when you 3D touch on an item.
3. You can like and dislike on the movie detailed page.
4. Popular movies will be shown on the movie page when you load the page for the first time as well as when the search query is empty.


Reference:
1. https://github.com/HanHan120766/LoadingDemo/tree/master (LoadingView)
2. https://stackoverflow.com/questions/16100378/is-there-any-controls-available-for-star-rating (Stars rating)
3. https://www.youtube.com/watch?v=s32FuDBGBf8 (SQLite3)
4. https://stackoverflow.com/questions/56984247/swift-how-to-remove-special-character-without-remove-emoji-from-string (Filter search query)



