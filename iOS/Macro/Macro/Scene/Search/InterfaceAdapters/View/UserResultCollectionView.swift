//
//  UserResultCollectionView.swift
//  Macro
//
//  Created by 김나훈 on 12/5/23.
//

import Foundation

import Foundation
import UIKit

final class UserResultCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let viewModel: SearchViewModel
    
    init(frame: CGRect, viewModel: SearchViewModel) {
        self.viewModel = viewModel
        let layout = UICollectionViewFlowLayout()
        super.init(frame: frame, collectionViewLayout: layout)
        self.register(UserResultCell.self, forCellWithReuseIdentifier: "UserResultCell")
        self.dataSource = self
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.userList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserResultCell", for: indexPath) as? UserResultCell else {
            return UICollectionViewCell()
        }
        let user = viewModel.userList[indexPath.row]
        cell.configure(with: user)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.width - 20, height: 30)
    }
}
