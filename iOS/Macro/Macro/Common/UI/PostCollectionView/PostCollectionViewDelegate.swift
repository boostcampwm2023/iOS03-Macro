//
//  PostContentDelegate.swift
//  Macro
//
//  Created by 김나훈 on 12/4/23.
//

import Foundation

protocol PostCollectionViewDelegate: AnyObject {
    func didTapContent(postId: Int, viewController: ReadViewController)
}
