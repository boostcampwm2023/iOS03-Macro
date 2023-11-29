//
//  RouteViewModel.swift
//  Macro
//
//  Created by Byeon jinha on 11/29/23.
//

import Combine
import Foundation
import MacroNetwork

class RouteViewModel: ViewModelProtocol, MapCollectionViewProtocol {

    // MARK: - Propertieds
    var travels: [TravelInfo] = []
    private var cancellables = Set<AnyCancellable>()
    private let outputSubject = PassthroughSubject<Output, Never>()
    
    let writeViewModel = WriteViewModel(uploadImageUseCase: UploadImage(provider: APIProvider(session: URLSession.shared)))
    lazy var writeViewController = WriteViewController(viewModel: writeViewModel)
    
    // MARK: - Input
    
    enum Input {
    }
    
    // MARK: - Output
    
    enum Output {
        case deleteTravel(String)
        case navigateToWriteView(TravelInfo)
    }
    
    // MARK: - Methods
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] _ in
        }.store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    func navigateToWriteView(travelInfo: TravelInfo) {
        self.outputSubject.send(.navigateToWriteView(travelInfo))
    }
                                
    func deleteTravel(uuid: String) {
        self.outputSubject.send(.deleteTravel(uuid))
    }
}
