//
//  ViewController.swift
//  ios101-project5-tumbler
//

import UIKit
import Nuke
import NukeExtensions



class ViewController: UIViewController, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create the cell
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        let post = posts[indexPath.row]
        
        // Set the summary text on the custom label
        cell.summaryLabel.text = post.summary

        // Load the image with Nuke, if available
        if let photo = post.photos.first {
            let imageUrl = photo.originalSize.url

            Nuke.ImagePipeline.shared.loadImage(
                with: imageUrl,
                completion: { result in
                    switch result {
                    case .success(let response):
                        cell.postImageView.image = response.image
                    case .failure(let error):
                        print("❌ Image load error: \(error)")
                        cell.postImageView.image = nil  // or placeholder
                    }
                }
            )
        }

        
        // Return the cell for use in the respective table view row
        return cell
    }
    

    @IBOutlet weak var tableView: UITableView!
    
    private var posts: [Post] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 150

            fetchPosts()
        }

    



    func fetchPosts() {
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork/posts/photo?api_key=1zT8CiXGXFcQDyMFG7RtcfGLwTdDjFUJnZzKJaWTmgyK4lKGYk")!
        let session = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200...299).contains(statusCode) else {
                print("❌ Response error: \(String(describing: response))")
                return
            }

            guard let data = data else {
                print("❌ Data is NIL")
                return
            }

            do {
                let blog = try JSONDecoder().decode(Blog.self, from: data)
                let posts = blog.response.posts
                
                DispatchQueue.main.async { [weak self] in
                    self?.posts = posts
                    self?.tableView.reloadData()
                
                    let posts = blog.response.posts


                    print("✅ We got \(posts.count) posts!")
                    for post in posts {
                        print("🍏 Summary: \(post.summary)")
                    }
                }

            } catch {
                print("❌ Error decoding JSON: \(error.localizedDescription)")
            }
        }
        session.resume()
    }
}
