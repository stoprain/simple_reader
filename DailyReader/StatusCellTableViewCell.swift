//
//  StatusCellTableViewCell.swift
//  DailyReader
//
//  Created by Rain Qian on 2019/10/6.
//

import UIKit
import Kingfisher

class StatusCellTableViewCell: UITableViewCell {

  let avatar = UIImageView()
  let nameLabel = UILabel()
  let detailLabel = UILabel()
  let retweetedDetailLabel = UILabel()
  let createdAtLabel = UILabel()
  let imageContainer = UIView()
  var imageContainerHeight: NSLayoutConstraint?
  
  var status: Status? {
    didSet {
      guard let status = status else {
        return
      }
      if let user = status.user {
        let url = URL(string: user.profileImageUrl)
        avatar.kf.setImage(with: url)
        nameLabel.text = user.name
      }
      
      let formatter = DateFormatter()
      formatter.dateStyle = .full
      createdAtLabel.text = formatter.string(from: status.createdAt)
      detailLabel.text = status.text
      if let s = status.retweetedStatus {
        retweetedDetailLabel.text = "\(s.user?.name ?? "") " + s.text
      }
      
      if let pics = status.picUrls, pics.count > 0 {
        let containerWidth = UIScreen.main.bounds.width - 32
        var itemWidth = containerWidth
        if pics.count > 6 {
          imageContainerHeight?.constant = containerWidth
          itemWidth = containerWidth / 3
        } else if pics.count > 3 {
          imageContainerHeight?.constant = containerWidth / 3 * 2
          itemWidth = containerWidth / 3
        } else if pics.count == 3 {
          imageContainerHeight?.constant = containerWidth / 3
          itemWidth = containerWidth / 3
        } else if pics.count == 2 {
          imageContainerHeight?.constant = containerWidth / 2
          itemWidth = containerWidth / 2
        } else if pics.count == 1 {
          imageContainerHeight?.constant = containerWidth
          itemWidth = containerWidth
        }
        
        for i in 0..<pics.count {
          let pic = pics[i]
          let row: Int = i / 3
          let column = i % 3
          let item = UIImageView()
          imageContainer.addSubview(item)
          let url = URL(string: pic.thumbnailPic)
          item.kf.setImage(with: url)
          item.frame = CGRect(x: CGFloat(column) * itemWidth, y: CGFloat(row) * itemWidth, width: itemWidth, height: itemWidth)
        }
        
      } else {
        imageContainerHeight?.constant = 0
      }
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    avatar.image = nil
    nameLabel.text = nil
    createdAtLabel.text = nil
    detailLabel.text = nil
    retweetedDetailLabel.text = nil
    for v in imageContainer.subviews {
      v.removeFromSuperview()
    }
  }
  
  // MARK: Initalizers
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    selectionStyle = .none
    
    let marginGuide = contentView.layoutMarginsGuide
    
    contentView.addSubview(avatar)
    avatar.translatesAutoresizingMaskIntoConstraints = false
    avatar.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
    avatar.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
    avatar.widthAnchor.constraint(equalToConstant: 36).isActive = true
    avatar.heightAnchor.constraint(equalToConstant: 36).isActive = true
    
    contentView.addSubview(nameLabel)
    nameLabel.translatesAutoresizingMaskIntoConstraints = false
    nameLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor).isActive = true
    nameLabel.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
    nameLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
    nameLabel.numberOfLines = 0
    nameLabel.font = UIFont.systemFont(ofSize: 14)
    nameLabel.textColor = UIColor.red

    contentView.addSubview(createdAtLabel)
    createdAtLabel.translatesAutoresizingMaskIntoConstraints = false
    createdAtLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor).isActive = true
    createdAtLabel.bottomAnchor.constraint(equalTo: avatar.bottomAnchor).isActive = true
    createdAtLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
    createdAtLabel.numberOfLines = 0
    createdAtLabel.font = UIFont.systemFont(ofSize: 12)
    createdAtLabel.textColor = UIColor.lightGray

    contentView.addSubview(detailLabel)
    detailLabel.translatesAutoresizingMaskIntoConstraints = false
    detailLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
    detailLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
    detailLabel.topAnchor.constraint(equalTo: avatar.bottomAnchor).isActive = true
    detailLabel.numberOfLines = 0
    detailLabel.font = UIFont.systemFont(ofSize: 14)

    contentView.addSubview(retweetedDetailLabel)
    retweetedDetailLabel.translatesAutoresizingMaskIntoConstraints = false
    retweetedDetailLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
    retweetedDetailLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
    retweetedDetailLabel.topAnchor.constraint(equalTo: detailLabel.bottomAnchor).isActive = true
    retweetedDetailLabel.numberOfLines = 0
    retweetedDetailLabel.font = UIFont.systemFont(ofSize: 14)
    retweetedDetailLabel.backgroundColor = UIColor.lightGray

    contentView.addSubview(imageContainer)
    imageContainer.translatesAutoresizingMaskIntoConstraints = false
    imageContainer.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
    imageContainer.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
    imageContainer.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
    imageContainer.topAnchor.constraint(equalTo: retweetedDetailLabel.bottomAnchor).isActive = true
    imageContainerHeight = imageContainer.heightAnchor.constraint(equalToConstant: 0)
    imageContainerHeight?.priority = .defaultLow
    imageContainerHeight?.isActive = true
//    imageContainer.axis = .horizontal
//    imageContainer.spacing = 10
//    imageContainer.distribution = .equalCentering
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

