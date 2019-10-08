//
//  CommentsTableViewController.swift
//  DailyReader
//
//  Created by Rain Qian on 2019/10/6.
//

import UIKit

class CommentsTableViewController: UITableViewController {
  
  var idstr: String = ""
  var comments = [Comment]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    fetchWeatherData()
  }
  
  @objc
  private func fetchWeatherData() {
    let urlString = "https://api.weibo.com/2/comments/show.json?count=100&access_token=&id=\(idstr)"
    print(urlString)
    if let url = URL(string: urlString) {
      URLSession.shared.dataTask(with: url) { (data, resp, err) in
        do {
          let decoder = JSONDecoder()
          let dateFormatterGet = DateFormatter()
          dateFormatterGet.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
          decoder.keyDecodingStrategy = .convertFromSnakeCase
          decoder.dateDecodingStrategy = .formatted(dateFormatterGet)
          let json = try decoder.decode(CommentsShow.self, from: data!)
            self.comments = json.comments
            DispatchQueue.main.async {
              self.tableView.reloadData()
              self.refreshControl?.endRefreshing()
            }
        } catch let e {
          print(e)
        }
      }.resume()
    }
  }


  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return comments.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
    cell.textLabel?.text = comments[indexPath.row].text
    return cell
  }

}
