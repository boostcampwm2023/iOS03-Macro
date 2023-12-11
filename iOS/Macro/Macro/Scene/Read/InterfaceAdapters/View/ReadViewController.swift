//
//  ReadViewController.swift
//  Macro
//
//  Created by Byeon jinha on 11/21/23.
//

import Combine
import NMapsMap
import MacroNetwork
import UIKit

final class ReadViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: ReadViewModel
    private var readPost: ReadPost?
    private var cancellables = Set<AnyCancellable>()
    private let didScrollSubject: PassthroughSubject<Int, Never> = .init()
    private var readViewDisappear: PassthroughSubject<ReadPost, Never> = .init()
    private let inputSubject: PassthroughSubject<ReadViewModel.Input, Never> = .init()
    private var routeOverlay: NMFPath?
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private let scrollContentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var postProfile: ReadProfileView = {
        let view = ReadProfileView(inputSubject: self.inputSubject)
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.appColor(.blue5)
        label.font = UIFont.appFont(.baeEunTitle1)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var reportButtomImageView: UIImageView = {
        let image: UIImage? = UIImage.appImage(.exclamationmarkBubble)
        let imageView = UIImageView(image: image)
        imageView.tintColor = UIColor.appColor(.purple4)
        return imageView
    }()
    
    private lazy var carouselView: MacroCarouselView = MacroCarouselView(
        didScrollOutputSubject: didScrollSubject,
        inputSubject: inputSubject,
        viewModel: viewModel)
    
    private let likeImageView: UIImageView = {
        let image: UIImage? = UIImage.appImage(.handThumbsup)
        let imageView: UIImageView = UIImageView()
        imageView.image = image
        imageView.tintColor = UIColor.appColor(.purple5)
        return imageView
    }()
    
    private let likeCountLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = UIColor.appColor(.purple5)
        label.font = UIFont.appFont(.baeEunBody)
        return label
    }()
    
    private let viewImageView: UIImageView = {
        let image: UIImage? = UIImage.appImage(.eyes)
        let imageView: UIImageView = UIImageView()
        imageView.image = image
        imageView.tintColor = UIColor.appColor(.purple5)
        return imageView
    }()
    
    private let viewCountLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = UIColor.appColor(.purple5)
        label.font = UIFont.appFont(.baeEunBody)
        return label
    }()
    
    private let mapView: NMFMapView = {
        let mapView = NMFMapView()
        mapView.positionMode = .normal
        mapView.layer.cornerRadius = 20
        mapView.layer.borderWidth = 1
        mapView.layer.borderColor = UIColor.appColor(.purple1).cgColor
        return mapView
    }()
    
    private var markers: [String: NMFMarker] = [:]
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        bind()
        setLayout()
        self.view.backgroundColor = .white
        
        inputSubject.send(.readPosts)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        inputSubject.send(.didDisappear)
    }
    
    // MARK: - init
    
    init(viewModel: ReadViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    init(viewModel: ReadViewModel, readViewDisappear: PassthroughSubject<ReadPost, Never>) {
        self.viewModel = viewModel
        self.readViewDisappear = readViewDisappear
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Handle Gesture
    
    @objc private func likeImageViewTap(_ sender: UITapGestureRecognizer) {
        likeImageView.isUserInteractionEnabled = false
        inputSubject.send(.likeImageTap)
    }
    
    @objc private func reportButtonTouched(_ sender: UITapGestureRecognizer) {
        AlertBuilder(viewController: self)
            .setTitle("신고하기")
            .setMessage("정말 게시물을 신고 하시겠어요?")
            .addActionConfirm("확인") {
                guard let postId = self.readPost?.postId,
                      let title = self.readPost?.title,
                      let description = self.readPost?.writer.email
                else { return }
                self.inputSubject.send(.reportPost("\(postId)", title, description))
                self.view.showToast(message: "정상적으로 신고되었습니다.")
            }.addActionCancel("취소") {
               
            }
            .show()
    }
}

// MARK: - UI Settings

private extension ReadViewController {
    
    func setTranslatesAutoresizingMaskIntoConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        postProfile.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        carouselView.translatesAutoresizingMaskIntoConstraints = false
        likeImageView.translatesAutoresizingMaskIntoConstraints = false
        likeCountLabel.translatesAutoresizingMaskIntoConstraints = false
        viewImageView.translatesAutoresizingMaskIntoConstraints = false
        viewCountLabel.translatesAutoresizingMaskIntoConstraints = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        reportButtomImageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func addSubviews() {
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(scrollContentView)
        [
            postProfile,
            titleLabel,
            carouselView,
            likeImageView,
            likeCountLabel,
            viewImageView,
            viewCountLabel,
            mapView,
            reportButtomImageView
        ].forEach { self.scrollContentView.addSubview($0) }
    }
    
    func setLayoutConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            postProfile.topAnchor.constraint(equalTo: scrollContentView.topAnchor),
            postProfile.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 10),
            postProfile.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -10),
            postProfile.heightAnchor.constraint(equalToConstant: 50),
            
            reportButtomImageView.topAnchor.constraint(equalTo: scrollContentView.topAnchor),
            reportButtomImageView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -20),
            reportButtomImageView.heightAnchor.constraint(equalToConstant: 30),
            reportButtomImageView.widthAnchor.constraint(equalToConstant: 30),
            
            titleLabel.topAnchor.constraint(equalTo: postProfile.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor),
            
            carouselView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            carouselView.heightAnchor.constraint(equalToConstant: 400),
            carouselView.widthAnchor.constraint(equalToConstant: UIScreen.width),
            
            likeImageView.topAnchor.constraint(equalTo: carouselView.bottomAnchor, constant: 40),
            likeImageView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 24),
            
            likeCountLabel.centerYAnchor.constraint(equalTo: likeImageView.centerYAnchor),
            likeCountLabel.leadingAnchor.constraint(equalTo: likeImageView.trailingAnchor, constant: 10),
            
            viewImageView.topAnchor.constraint(equalTo: carouselView.bottomAnchor, constant: 40),
            viewImageView.leadingAnchor.constraint(equalTo: likeCountLabel.trailingAnchor, constant: 10),
            
            viewCountLabel.centerYAnchor.constraint(equalTo: viewImageView.centerYAnchor),
            viewCountLabel.leadingAnchor.constraint(equalTo: viewImageView.trailingAnchor, constant: 10),
            
            scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollContentView.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            mapView.topAnchor.constraint(equalTo: likeImageView.bottomAnchor, constant: 10),
            mapView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 24),
            mapView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -24),
            mapView.heightAnchor.constraint(equalToConstant: UIScreen.width - 48),
            mapView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor, constant: -50)
        ])
    }
    
    func setLayout() {
        setTranslatesAutoresizingMaskIntoConstraints()
        addSubviews()
        setLayoutConstraints()
        postProfile.setLayout()
        addTapGesture()
    }
    
    func addTapGesture() {
        likeImageView.isUserInteractionEnabled = true
        let likeImageViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(likeImageViewTap(_:)))
        likeImageView.addGestureRecognizer(likeImageViewTapGesture)
        
        reportButtomImageView.isUserInteractionEnabled = true
        let reportTapGesture = UITapGestureRecognizer(target: self, action: #selector(reportButtonTouched(_:)))
        reportButtomImageView.addGestureRecognizer(reportTapGesture)
    }
}

// MARK: - Bind

private extension ReadViewController {
    func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        
        outputSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] output in
                switch output {
                case let .updatePost(post):
                    self?.updatePost(post)
                case let .navigateToProfileView(userID):
                    self?.navigateToProfileView(userID)
                case let .updatePageIndex(index):
                    self?.updatePageIndex(index)
                case let .updatePostLike(likePostResponse):
                    self?.likeCountLabel.text = "\(likePostResponse.likeNum)"
                    self?.likeImageView.image = likePostResponse.liked ? UIImage.appImage(.handThumbsupFill) : UIImage.appImage(.handThumbsup)
                    self?.likeImageView.tintColor = likePostResponse.liked ? UIColor.appColor(.purple2) : UIColor.appColor(.purple5)
                    self?.likeImageView.isUserInteractionEnabled = true
                case let .updatePostCollection(post):
                    guard let post else { return }
                    self?.readViewDisappear.send(post)
                }
            }
            .store(in: &cancellables)
        
        didScrollSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] index in
                self?.carouselView.descriptionLabel.text = self?.readPost?.contents[index].description
                self?.carouselView.descriptionLabel.text = self?.readPost?.contents[index].description
                self?.handleScrollEvent(index: index)
                if let coordinate = self?.readPost?.contents[index].coordinate {
                    let centerLocation = NMGLatLng(
                        lat: coordinate.yPosition,
                        lng: coordinate.xPosition)
                    let cameraUpdate = NMFCameraUpdate(scrollTo: centerLocation)
                    cameraUpdate.animation = .easeIn
                    self?.mapView.moveCamera(cameraUpdate)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Methods

private extension ReadViewController {
    
    func updatePageIndex(_ index: Int) {
        self.carouselView.pageController.currentPage = viewModel.pageIndex
        self.didScrollSubject.send(viewModel.pageIndex)
    }
    
    func navigateToProfileView(_ userId: String) {
        let provider = APIProvider(session: URLSession.shared)
        let searchUseCase = Searcher(provider: provider)
        let followFeature = FollowFeature(provider: provider)
        let userInfoViewModel = UserInfoViewModel(postSearcher: searchUseCase, followFeature: followFeature, patcher: Patcher(provider: provider))
        let userInfoViewController = UserInfoViewController(viewModel: userInfoViewModel, userInfo: userId)
        
        navigationController?.pushViewController(userInfoViewController, animated: true)
    }
    
    func updatePost(_ readPost: ReadPost) {
        self.readPost = readPost
        
        likeCountLabel.text = "\(readPost.likeNum)"
        
        viewCountLabel.text = "\(readPost.viewNum)"
        
        postProfile.updateProfil(readPost.writer)
        
        titleLabel.text = readPost.title
        
        let email = TokenManager.extractEmailFromJWTToken()
        
        reportButtomImageView.isHidden = readPost.writer.email == email
        
        carouselView.descriptionLabel.text = readPost.contents.first?.description
        
        let imageURLs = readPost.contents.compactMap { $0.imageURL }
        downloadImages(imageURLs: imageURLs) { [weak self] images in
            self?.carouselView.updateData(images)
        }
        
        self.likeImageView.image = readPost.liked ? UIImage.appImage(.handThumbsupFill) : UIImage.appImage(.handThumbsup)
        self.likeImageView.tintColor = readPost.liked ? UIColor.appColor(.purple2) : UIColor.appColor(.purple5)
        
        calculateCenterLocation(routePoints: readPost.route.coordinates)
        updateMapWithLocation(routePoints: readPost.route.coordinates )
        
        updateMark(recordedPindedInfo: readPost.pins)
           if let firstPin = readPost.pins.first {
               updateFirstMarkerColor(placeId: firstPin.placeId)
           }
        
    }
    
    func downloadImages(imageURLs: [String], completion: @escaping ([UIImage?]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var images: [UIImage?] = Array(repeating: nil, count: imageURLs.count)
        
        imageURLs.enumerated().forEach { index, imageURL in
            dispatchGroup.enter()
            
            if let url = URL(string: imageURL) {
                URLSession.shared.dataTask(with: url) { (data, _, _) in
                    defer {
                        dispatchGroup.leave()
                    }
                    if let data = data, let image = UIImage(data: data) {
                        images[index] = image
                    } else {
                        debugPrint("Failed to download image form \(url)")
                    }
                }.resume()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(images)
        }
    }
    
    func calculateCenterLocation(routePoints: [Coordinate]) {
        var maxLatitude = -90.0
        var minLatitude = 90.0
        var maxLongitude = -180.0
        var minLongitude = 180.0
        
        for point in routePoints {
            let latitude = point.yPosition
            let longitude = point.xPosition
            
            if latitude > maxLatitude {
                maxLatitude = latitude
            }
            if latitude < minLatitude {
                minLatitude = latitude
            }
            if longitude > maxLongitude {
                maxLongitude = longitude
            }
            if longitude < minLongitude {
                minLongitude = longitude
            }
        }
        
        let centerLatitude = (maxLatitude + minLatitude) / 2.0
        let centerLongitude = (maxLongitude + minLongitude) / 2.0
        
        let centerLocation = NMGLatLng(lat: centerLatitude, lng: centerLongitude)
        let distanceLatitude = abs(maxLatitude - minLatitude)
        let distanceLongitude = abs(maxLongitude - minLongitude)
        
        let zoomLevelLatitude = log2(90 / distanceLatitude)
        let zoomLevelLongitude = log2(90 / distanceLongitude)
        let zoomLevel = min(zoomLevelLatitude, zoomLevelLongitude)
        mapView.zoomLevel = zoomLevel
        
        let cameraUpdate = NMFCameraUpdate(scrollTo: centerLocation )
        mapView.moveCamera(cameraUpdate)
    }
    
    /// 이동 경로를 입력받아 지도에 그립니다.
    /// - Parameters:
    ///   - routePoints: 위도, 경도 배열 입니다.
    func updateMapWithLocation(routePoints: [Coordinate]) {
        routeOverlay?.mapView = nil
        let coords = routePoints.map { NMGLatLng(lat: $0.yPosition, lng: $0.xPosition) }
        routeOverlay = NMFPath(points: coords)
        routeOverlay?.color = UIColor.appColor(.purple1)
        routeOverlay?.mapView = mapView
    }
    
    /// Pin이 저장된 곳에  Mark를 찍습니다.
    /// - Parameters:
    ///   - recordedPindedInfo: Pin의 위도, 경도 배열 입니다.
    func updateMark(recordedPindedInfo: [Pin]) {
        markers.values.forEach { $0.mapView = nil }
        markers.removeAll()

        for pin in recordedPindedInfo {
            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: pin.coordinate.yPosition, lng: pin.coordinate.xPosition)
            marker.captionText = pin.placeName
            marker.mapView = mapView
            marker.touchHandler = { [weak self] _ in
                // handleMarkerTap 함수를 호출할 때, pin 객체를 전달합니다.
                self?.handleMarkerTap(pin)
                return true
            }
            markers[pin.placeId] = marker
        }
    }
    
    func updateFirstMarkerColor(placeId: String) {
        if let marker = markers[placeId] {
            marker.iconTintColor = UIColor.appColor(.red4)
        }
    }
    
    func handleScrollEvent(index: Int) {
           guard let pin = readPost?.pins[index] else { return }
           let marker = markers[pin.placeId]
        markers.values.forEach { $0.iconTintColor = UIColor.clear }
        marker?.iconTintColor = UIColor.appColor(.red4)
       }
    
    func handleMarkerTap(_ placeInfo: Pin) {
        let locationDetail = LocationDetail(addressName: placeInfo.address, categoryGroupCode: placeInfo.category, categoryGroupName: "-", categoryName: "-", distance: "", id: placeInfo.placeId, phone: placeInfo.phoneNumber, placeName: placeInfo.placeName, placeUrl: "", roadAddressName: placeInfo.roadAddress ?? "", mapx: "", mapy: "")
        let searcher = Searcher(provider: APIProvider(session: URLSession.shared))
        let locationInfoVC = LocationInfoViewController(viewModel: LocationInfoViewModel(locationDetail: locationDetail, searcher: searcher))
        navigationController?.pushViewController(locationInfoVC, animated: true)
    }
}

// MARK: - LayoutMetrics
private extension ReadViewController {
    enum Metrics {
        static let profileImageViewWidth: CGFloat = 36
        static let profileImageViewHeight: CGFloat = 36
        static let viewImageViewWidth: CGFloat = 16
        static let viewImageViewHeight: CGFloat = 16
        static let likeImageViewWidth: CGFloat = 16
        static let likeImageViewHieght: CGFloat = 16
    }
    
    enum Padding {
        static let profileImageViewLeading: CGFloat = 10
        static let userNameLabelLeading: CGFloat = 10
        static let viewCountLabelTrailing: CGFloat = -10
        static let viewImageViewTrailing: CGFloat = -10
        static let likeCountLabelTrailing: CGFloat = -20
        static let likeImageViewTrailing: CGFloat = -10
    }
}
