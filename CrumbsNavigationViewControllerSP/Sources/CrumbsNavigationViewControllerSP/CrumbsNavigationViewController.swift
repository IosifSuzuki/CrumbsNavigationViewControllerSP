//
//  ExtraNavigationControllerViewController.swift
//  ExtraNavigationController
//
//  Created by Bogdan Petkanitch on 20.08.2022.
//

import UIKit
import Logging

public protocol IViewControllerTitleRepresentation {
  var navigationCrumbTitle: String { get }
}

open class CrumbsNavigationViewController: UINavigationController {
  
  private var collectionView: UICollectionView!
  
  public var seperatorIconImageBetweenCrumbs: UIImage?
  
  private let logger = Logger(label: "CrumbsNavigationViewControllerSP")
  
  public var backgroundColor: UIColor = .clear {
    didSet {
      rewriteNavigationBarAppearance()
    }
  }
  public var titleColor: UIColor = .white {
    didSet {
      rewriteNavigationBarAppearance()
    }
  }

  private var dataSource: [NavigationViewCollectionViewModelCell] = []
  
  open override func loadView() {
    super.loadView()
    
    setupCollectionView()
  }
  
  open override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView.isHidden = true
    delegate = self
  }
  
  open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
    let prevViewController = viewControllers.last
    super.pushViewController(viewController, animated: animated)
    if collectionView.isHidden, viewControllers.count > 1 {
      collectionView(topViewController: viewController, display: true)
    }
    guard let previousViewController = prevViewController else {
      return
    }
    let title: String
    if !dataSource.isEmpty {
      dataSource[dataSource.count - 1].displayRightArrow = true
    }
    if let viewController = previousViewController as? IViewControllerTitleRepresentation {
      title = viewController.navigationCrumbTitle
    } else {
      title = previousViewController.title ?? ""
    }
    let cellViewModel: NavigationViewCollectionViewModelCell = .init(title: title, displayRightArrow: false)
    dataSource.append(cellViewModel)
    
    previousViewController.additionalSafeAreaInsets.top = Defaults.bottomExtraViewHeight
  }
  
  open override func popViewController(animated: Bool) -> UIViewController? {
    if !dataSource.isEmpty {
      dataSource.removeLast()
      if !dataSource.isEmpty {
        dataSource[dataSource.count - 1].displayRightArrow = false
      }
      if viewControllers.count == 2 {
        collectionView(topViewController: viewControllers[viewControllers.count - 2], display: false)
      }
    }
    
    return super.popViewController(animated: animated)
  }
  
  // MARK: - Private Methods
  
  private func rewriteNavigationBarAppearance() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.titleTextAttributes = [
      .foregroundColor: titleColor
    ]
    appearance.backgroundColor = backgroundColor
    navigationBar.standardAppearance = appearance;
    navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
    navigationBar.tintColor = titleColor
    collectionView?.backgroundColor = backgroundColor
  }
  
  private func setupCollectionView() {
    let tagLayout = TagLayoutCollectionView()
    tagLayout.scrollDirection = .horizontal
    collectionView = .init(frame: .zero, collectionViewLayout: tagLayout)
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    collectionView.contentInset = .init(top: .zero, left: 8, bottom: .zero, right: 8)
    collectionView.backgroundColor = backgroundColor
    collectionView.alwaysBounceHorizontal = true
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(collectionView)
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.heightAnchor.constraint(equalToConstant: Defaults.bottomExtraViewHeight)
    ])
    
    collectionView.register(NavigationCrumbCollectionViewCell.self, forCellWithReuseIdentifier: NavigationCrumbCollectionViewCell.reuseIdentifier)
    tagLayout.delegate = self
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.reloadData()
  }
  
  private func collectionView(topViewController: UIViewController?, display: Bool) {
    topViewController?.additionalSafeAreaInsets.top = display ? Defaults.bottomExtraViewHeight : .zero
    UIView.animate(withDuration: 1.0, delay: .zero, options: .curveEaseOut) { [weak self] in
      self?.collectionView.isHidden = !display
      self?.topViewController?.view.layoutIfNeeded()
    }
  }
  
  private func updateCollectionViewStates(viewController: UIViewController? = nil) {
    collectionView.reloadData()
    collectionView.collectionViewLayout.invalidateLayout()
  }
  
  private enum Defaults {
    static let bottomExtraViewHeight: CGFloat = 60
  }
}

extension CrumbsNavigationViewController: UICollectionViewDataSource {
  
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataSource.count
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cellView = collectionView.dequeueReusableCell(
      withReuseIdentifier: NavigationCrumbCollectionViewCell.reuseIdentifier,
      for: indexPath
    ) as! NavigationCrumbCollectionViewCell
    let cellViewModel = dataSource[indexPath.row]
    cellView.setup(with: cellViewModel)
    cellView.set(rightImage: self.seperatorIconImageBetweenCrumbs)
    cellView.set(mainColor: titleColor)
    return cellView
  }
  
}

extension CrumbsNavigationViewController: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let dataSourceCountBeforePopTo = dataSource.count
    for idx in indexPath.row..<dataSource.count {
      let _ = popViewController(animated: idx == dataSourceCountBeforePopTo - 1)
    }
  }
}

extension CrumbsNavigationViewController: UINavigationControllerDelegate {
  
  public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    viewController.navigationItem.backButtonTitle = ""
    updateCollectionViewStates()
    logger.debug("Will show viewController \(viewController.title ?? "<???>")")
  }
  
  public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
    collectionView.collectionViewLayout.invalidateLayout()
    if !dataSource.isEmpty {
      let targetIndexPath = IndexPath(row: dataSource.count - 1, section: 0)
      logger.info("Will scrolling to targetIndexPath \(targetIndexPath)")
      if collectionView.cellForItem(at: targetIndexPath) != nil {
        collectionView.scrollToItem(at: targetIndexPath, at: .right, animated: true)
        logger.info("End scrolling to targetIndexPath \(targetIndexPath)")
      }
    }
  }
  
}

extension CrumbsNavigationViewController: TagLayoutCollectionViewDelegate {
  
  func sizeForTagCell(by index: Int) -> CGSize {
    let indexPath = IndexPath(row: index, section: 0)
    guard let cellNavigationCrumbCollectionViewCell = collectionView.cellForItem(at: indexPath) as? ICellSizeToFit else {
      return .zero
    }
    return cellNavigationCrumbCollectionViewCell.calculateOptimalSizeOfCell
  }
  
}

extension CrumbsNavigationViewController: UICollectionViewDelegateFlowLayout {
  
}
