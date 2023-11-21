//
//  SearchViewController.swift
//  Macro
//
//  Created by Byeon jinha on 11/20/23.
//

import Foundation

final class SearchViewController: TabViewController {
    let viewModel: SearchViewModel
    
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
