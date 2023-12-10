//
//  TabBarViewModel.swift
//  Macro
//
//  Created by Byeon jinha on 11/14/23.
//

import Combine
import MacroDesignSystem
import MacroNetwork
import Network
import UIKit

final class TabBarViewModel {
    let tabComponentArray = CurrentValueSubject<[TabComponent], Never>([])
    var currentTabComponent: CurrentValueSubject<TabComponent, Never>
    var radius: CGFloat = 90
    var rotationAngle: Double = 0
    var timer: Timer?
    var isTabBarActive: Bool = false
    var animationStep: Int = 0
    
    init() {
        let provider = APIProvider(session: URLSession.shared)
        let searchViewModel = SearchViewModel(searcher: Searcher(provider: provider), patcher: Patcher(provider: provider))
        let homeViewModel = HomeViewModel(postSearcher: Searcher(provider: provider), followFeature: FollowFeature(provider: provider), patcher: Patcher(provider: provider))
        let routeViewModel = RouteViewModel()
        let travelViewModel = TravelViewModel(
            locationSearcher: Searcher(provider: provider),
            pinnedPlaceManager: PinnedPlaceManager(provider: provider))
        let myPageViewModel = MyPageViewModel(patcher: Patcher(provider: provider), 
                                              searcher: Searcher(provider: provider),
                                              confirmer: Confirmer(),
                                              uploader: UploadImage(provider: provider),
                                              revoker: Revoker(provider: provider))
        let setComponentArray = [
        TabComponent(index: 1,
                     image: UIImage.appImage(.magnifyingglass),
                     text: "검색",
                     viewController: SearchViewController(viewModel: searchViewModel)),
        TabComponent(index: 2,
                     image: UIImage.appImage(.personCircle),
                     text: "내 정보",
                     viewController: MyPageViewController(viewModel: myPageViewModel)),
        TabComponent(index: 3,
                     image: UIImage.appImage(.squareAndPencil),
                     text: "기록",
                     viewController: RouteViewController(viewModel: routeViewModel)),
        TabComponent(index: 4,
                     image: UIImage.appImage(.map),
                     text: "여행",
                     viewController: TravelViewController(viewModel: travelViewModel))
        ]
        
        self.tabComponentArray.value = setComponentArray
        self.currentTabComponent = CurrentValueSubject<TabComponent, Never>(
            TabComponent(index: 0,
                         image: UIImage.appImage(.house),
                         text: "홈",
                         viewController: HomeViewController(viewModel: homeViewModel)))
        setTabComponetArray()
    }
    
    // MARK: - Method
    
    private func setTabComponetArray() {
    }
}
