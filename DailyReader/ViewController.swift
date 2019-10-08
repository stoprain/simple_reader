//
//  ViewController.swift
//  DailyReader
//
//  Created by Rain Qian on 2019/10/4.
//

import UIKit
import SVProgressHUD

class ViewController: UITableViewController {
    
  var statuses = [Status]()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Weibo"
    
    view.backgroundColor = UIColor.gray
    tableView.register(StatusCellTableViewCell.self, forCellReuseIdentifier: "cell")
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = UITableView.automaticDimension

    statuses = DBHelper.shared.getAll()
    if statuses.count == 0 {
      if let url = Bundle.main.url(forResource: "home_timeline", withExtension: "json") {
        if let data = try? Data(contentsOf: url) {
          do {
            let decoder = JSONDecoder()
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .formatted(dateFormatterGet)
            let json = try decoder.decode(HomeTimeline.self, from: data)
            for status in json.statuses {
              DBHelper.shared.add(status: status)
            }
            self.statuses = DBHelper.shared.getAll()
          } catch let e {
            print(e)
          }
        }
      }
    }
  
    refreshControl = UIRefreshControl()
    tableView.refreshControl = refreshControl
    refreshControl?.addTarget(self, action: #selector(ViewController.fetchWeatherData), for: .valueChanged)
  }
    
  @objc
  private func fetchWeatherData() {
    var urlString = "https://api.weibo.com/2/statuses/home_timeline.json?count=100&access_token="
    if let latest = DBHelper.shared.getLatest() {
      urlString += "&since_id=" + latest.idstr
    }
    print(urlString)
    if let url = URL(string: urlString) {
      URLSession.shared.dataTask(with: url) { (data, resp, err) in
        let decoder = JSONDecoder()
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(dateFormatterGet)
        if let json = try? decoder.decode(HomeTimeline.self, from: data!) {
          for status in json.statuses {
            DBHelper.shared.add(status: status)
          }
          self.statuses = DBHelper.shared.getAll()
          DispatchQueue.main.async {
            SVProgressHUD.showInfo(withStatus: "\(json.statuses.count) new weibo")
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            let i = IndexPath(row: json.statuses.count, section: 0)
            self.tableView.scrollToRow(at: i, at: .top, animated: false)
          }
        }
      }.resume()
    }
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return statuses.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! StatusCellTableViewCell
    cell.status = statuses[indexPath.row]
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let c = CommentsTableViewController(style: .plain)
    c.idstr = statuses[indexPath.row].idstr
    navigationController?.pushViewController(c, animated: true)
  }

}



