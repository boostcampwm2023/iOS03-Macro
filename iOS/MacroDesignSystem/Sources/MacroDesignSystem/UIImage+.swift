//
//  UIImage+.swift
//  
//
//  Created by Byeon jinha on 11/16/23.
//

import UIKit.UIImage

public enum ImageAsset {
    case magnifyingglass
    case house
    case personCircle
    case map
    case squareAndPencil
    case handThumbsup
    case handThumbsupFill
    case eyes
    case paperplane
    case lockFill
    case lockOpenFill
    case photo
    case person2Fill
    case chartBarDocHorizontal
}

@available(iOS 13.0, *)
public extension UIImage {
    static func appImage(_ name: ImageAsset) -> UIImage? {
        switch name {
        case .magnifyingglass:
            return UIImage(systemName: "magnifyingglass")
        case .house:
            return UIImage(systemName: "house")
        case .personCircle:
            return UIImage(systemName: "person.circle")
        case .map:
            return UIImage(systemName: "map")
        case .squareAndPencil:
            return UIImage(systemName: "square.and.pencil")
        case .handThumbsup:
            return UIImage(systemName: "hand.thumbsup")
        case .handThumbsupFill:
            return UIImage(systemName: "hand.thumbsup.fill")
        case .eyes:
            return UIImage(systemName: "eyes")
        case .paperplane:
            return UIImage(systemName: "paperplane")
        case .lockFill:
            return UIImage(systemName: "lock.fill")
        case .lockOpenFill:
            return UIImage(systemName: "lock.open.fill")
        case .photo:
            return UIImage(systemName: "photo")
        case .person2Fill:
            return UIImage(systemName: "person.2.fill")
        case .chartBarDocHorizontal:
            return UIImage(systemName: "chart.bar.doc.horizontal")
        }
    }
}
