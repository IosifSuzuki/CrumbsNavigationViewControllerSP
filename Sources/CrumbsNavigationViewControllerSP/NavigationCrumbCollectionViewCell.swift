//
//  NavigationCrumbCollectionViewCell.swift
//  ExtraNavigationController
//
//  Created by Bogdan Petkanitch on 20.08.2022.
//

import UIKit

protocol ICellSizeToFit {
  var calculateOptimalSizeOfCell: CGSize { get }
}

class NavigationCrumbCollectionViewCell: UICollectionViewCell, ICellSizeToFit {
  
  private var stackView: UIStackView!
  private var crumbTitle: UILabel!
  private var rightArrowImageView: UIImageView!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Class Properties
  
  static var reuseIdentifier: String {
    return String(describing: NavigationCrumbCollectionViewCell.self)
  }
  
  // MARK: - Internal Methods
  
  func setup(with viewModel: NavigationViewCollectionViewModelCell) {
    crumbTitle.text = viewModel.title
    rightArrowImageView.isHidden = !viewModel.displayRightArrow
  }
  
  func set(mainColor: UIColor) {
    rightArrowImageView.tintColor = mainColor
    crumbTitle.textColor = mainColor
  }
  
  func set(rightImage: UIImage?) {
    self.rightArrowImageView.image = rightImage
  }
  
  // MARK: - ICellSizeToFit
  
  var calculateOptimalSizeOfCell: CGSize {
    var sizeOfLabel = ((crumbTitle.text ?? "") as NSString).boundingRect(
      with: contentView.bounds.size,
      options: .usesLineFragmentOrigin,
      attributes: [.font: crumbTitle.font as Any],
      context: nil
    ).size.applying(CGAffineTransform.init(scaleX: 1.2, y: 1))
    if !rightArrowImageView.isHidden {
      sizeOfLabel.width += rightArrowImageView.bounds.width + stackView.spacing
    }
    sizeOfLabel.height = 40
    return sizeOfLabel
  }
  
  // MARK: - Private Methods
  
  private func setupView() {
    let titleLabel = UILabel()
    self.crumbTitle = titleLabel
    titleLabel.font = UIFont.systemFont(ofSize: 17)
    let iconImageView = UIImageView()
    iconImageView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor, multiplier: 1.0)
    ])
    iconImageView.contentMode = .scaleAspectFit
    iconImageView.layer.masksToBounds = true
    self.rightArrowImageView = iconImageView
    let rootStackView = UIStackView(arrangedSubviews: [titleLabel, iconImageView])
    self.stackView = rootStackView
    contentView.addSubview(rootStackView)
    rootStackView.translatesAutoresizingMaskIntoConstraints = false
    rootStackView.alignment = .center
    rootStackView.axis = .horizontal
    rootStackView.spacing = 8
    NSLayoutConstraint.activate([
      self.contentView.trailingAnchor.constraint(equalTo: rootStackView.trailingAnchor),
      self.contentView.bottomAnchor.constraint(equalTo: rootStackView.bottomAnchor),
      self.contentView.leadingAnchor.constraint(equalTo: rootStackView.leadingAnchor),
      self.contentView.topAnchor.constraint(equalTo: rootStackView.topAnchor),
    ])
  }
    
}
