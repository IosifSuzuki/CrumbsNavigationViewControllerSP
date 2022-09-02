//
//  TagLayoutCollectionView.swift
//  ExtraNavigationController
//
//  Created by Bogdan Petkanitch on 24.08.2022.
//

import UIKit

protocol TagLayoutCollectionViewDelegate: AnyObject {
  func sizeForTagCell(by index: Int) -> CGSize
}

class TagLayoutCollectionView: UICollectionViewFlowLayout {
  
  weak var delegate: TagLayoutCollectionViewDelegate?
  private var cachesLayoutAttributes: [UICollectionViewLayoutAttributes] = []
  var spaceBetweenItems: CGFloat = 8
  
  override public var collectionViewContentSize: CGSize {
    let width = cachesLayoutAttributes.last?.frame.maxX ?? .zero
    let height = collectionView?.frame.size.height ?? 0
    return CGSize(width: width, height: height)
  }
  
  override func prepare() {
    guard let numberOfItems = collectionView?.numberOfItems(inSection: 0),
          let delegate = self.delegate else {
      return
    }
    
    cachesLayoutAttributes = []
    
    var offsetX = self.collectionView?.contentInset.left ?? .zero
    var offsetY: CGFloat = .zero
    for index in 0..<numberOfItems {
      let targetIndexPath = IndexPath(row: index, section: 0)
      let cellLayoutAttribute = UICollectionViewLayoutAttributes(forCellWith: targetIndexPath)
      let size = delegate.sizeForTagCell(by: index)
      offsetY = (collectionView?.bounds.height ?? 0) / 2 - size.height / 2
      cellLayoutAttribute.frame = .init(origin: .init(x: offsetX, y: offsetY), size: size)
      offsetX += size.width + spaceBetweenItems
      cachesLayoutAttributes.append(cellLayoutAttribute)
    }
    
  }
  
  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
      guard cachesLayoutAttributes.count > indexPath.row else { return nil }
      return cachesLayoutAttributes[indexPath.row]
    }
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    return cachesLayoutAttributes
  }
}
