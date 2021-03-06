//
//  StoryboardInstantiable.swift
//  RadiosPeru
//
//  Created by Jeans Ruiz on 1/22/20.
//  Copyright © 2020 Jeans. All rights reserved.
//

import UIKit

public protocol StoryboardInstantiable: NSObjectProtocol {
  associatedtype InstantiableType
  static var defaultFileName: String { get }
  static func instantiateViewController(_ bundle: Bundle?) -> InstantiableType
}

public extension StoryboardInstantiable where Self: UIViewController {
  
  static var defaultFileName: String {
    return NSStringFromClass(Self.self).components(separatedBy: ".").last!
  }
  
  static func instantiateViewController(_ bundle: Bundle? = nil) -> Self {
    let fileName = defaultFileName
    let storyboard = UIStoryboard(name: fileName, bundle: bundle)
    guard let viewController = storyboard.instantiateInitialViewController() as? Self else {
      fatalError("Cannot instantiate initial view controller \(Self.self) from storyboard with name \(fileName)")
    }
    return viewController
  }
}
