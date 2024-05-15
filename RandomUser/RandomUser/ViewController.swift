//
//  ViewController.swift
//  RandomUser
//
//  Created by paytalab on 5/13/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

public enum ViewMode {
    case view
    case delete
}

class ViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    private let viewModel: ViewModel
    private let refreshTrigger = PublishSubject<Void>()
    private let fetchMoreTrigger = PublishSubject<Void>()
    private let viewMode = BehaviorRelay<ViewMode>(value: .view)
    private let layoutType = BehaviorRelay<Section>(value: .grid)
    private let disposeBag = DisposeBag()
    
    private let tabButtonStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()

    private let maleTabButton = TabButton(title: "남자")
    private let femaleTabButton = TabButton(title: "여자")
    private lazy var pageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        return pageViewController
    }()
    private lazy var pages: [UIViewController] = {
        let pages = [maleViewController, femaleViewController]
        return pages
    }()
    private let maleViewController = UserListViewController()
    private let femaleViewController = UserListViewController()
    private let floatingButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemBlue
        config.cornerStyle = .capsule
        button.configuration = config
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        button.layer.zPosition = 1
        button.setTitle("View 전환", for: .normal)
        return button
    }()
    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        bindView()
        bindViewModel()
        maleTabButton.isSelected = true
        pageViewController.setViewControllers([maleViewController], direction: .forward, animated: true, completion: nil)
    }
    
    private func setUI() {
        title = "Random Users"
        view.addSubview(tabButtonStackView)
        tabButtonStackView.addArrangedSubview(maleTabButton)
        tabButtonStackView.addArrangedSubview(femaleTabButton) 
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        view.addSubview(floatingButton)

        tabButtonStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(60)
        }
        
        pageViewController.view.snp.makeConstraints { make in
            make.top.equalTo(tabButtonStackView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        floatingButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.trailing.equalToSuperview().inset(20)
            make.width.equalTo(120)
            make.height.equalTo(44)
        }
       
    }
    
    private func bindView() {
        maleTabButton.rx.tap.bind { [weak self] in
            guard let self = self, !self.maleTabButton.isSelected else { return }
            self.maleTabButton.isSelected = true
            self.femaleTabButton.isSelected = false

            self.pageViewController.setViewControllers([self.pages[0]], direction: .reverse,
                                                       animated: true, completion: nil)
        }.disposed(by: disposeBag)
        femaleTabButton.rx.tap.bind { [weak self] in
            guard let self = self, !self.femaleTabButton.isSelected else { return }
            self.maleTabButton.isSelected = false
            self.femaleTabButton.isSelected = true
            self.pageViewController.setViewControllers([self.pages[1]], direction: .forward,
                                                       animated: true, completion: nil)
        }.disposed(by: disposeBag)
        floatingButton.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            switch self.layoutType.value {
            case .grid:
                self.layoutType.accept(.list)
            case .list:
                self.layoutType.accept(.grid)
            }
        }.disposed(by: disposeBag)
        
    }
    
    private func bindViewModel() {
        let input = ViewModel.Input(refresh: refreshTrigger, fetchMore: fetchMoreTrigger)
        let output = viewModel.transform(input: input)
        Observable.combineLatest(viewMode, layoutType, output.maleList)
            .observe(on: MainScheduler.instance)
            .bind { [weak self] viewMode, layoutType, maleList in
                self?.maleViewController.applyData(section: layoutType, userList: maleList)


            }.disposed(by: disposeBag)
        
        Observable.combineLatest(viewMode, layoutType, output.femaleList)
            .observe(on: MainScheduler.instance)
            .bind { [weak self] viewMode, layoutType, femaleList in
                self?.femaleViewController.applyData(section: layoutType, userList: femaleList)

            }.disposed(by: disposeBag)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController), viewControllerIndex > 0 else {
            return nil
        }
        return pages[viewControllerIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController),
              viewControllerIndex < pages.count - 1 else {
            return nil
        }
        return pages[viewControllerIndex + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let visibleViewController = pageViewController.viewControllers?.first,
           let index = pages.firstIndex(of: visibleViewController) {
            if index == 0 {
                maleTabButton.isSelected = true
                femaleTabButton.isSelected = false
            } else {
                femaleTabButton.isSelected = true
                maleTabButton.isSelected = false
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
enum Section {
    case grid
    case list
}

enum Item: Hashable {
    case grid(User)
    case list(User)
}

class UserListViewController: UIViewController, UICollectionViewDelegate {
    public var dataSource: UICollectionViewDiffableDataSource<Section, Item>?
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(GridCollectionViewCell.self, forCellWithReuseIdentifier: GridCollectionViewCell.id)
        collectionView.register(ListCollectionViewCell.self, forCellWithReuseIdentifier: ListCollectionViewCell.id)
        collectionView.delegate = self
        return collectionView
    }()
    init() {
        super.init(nibName: nil, bundle: nil)
        setDataSource()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        setUI()
    }
    
    
    public func applyData(section: Section, userList: [User]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section,Item>()
        switch section {
        case .grid:
            let items = userList.map { Item.grid($0) }
            let section = Section.grid
            snapshot.appendSections([section])
            snapshot.appendItems(items, toSection: section)
            dataSource?.apply(snapshot)

        case .list:
            let items = userList.map { Item.list($0) }
            let section = Section.list
            snapshot.appendSections([section])
            snapshot.appendItems(items, toSection: section)
            dataSource?.apply(snapshot)
        }

    }
    
    private func setUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

    }
    
    private func setDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
            
            if case let .grid(user) = item {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridCollectionViewCell.id, for: indexPath) as? GridCollectionViewCell
                cell?.apply(user: user)
                return cell
            } else if case let .list(user) = item {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListCollectionViewCell.id, for: indexPath) as? ListCollectionViewCell
                cell?.apply(user: user)
                return cell
            }
            
            return nil
        }
        
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            let section = self?.dataSource?.sectionIdentifier(for: sectionIndex)
            switch section {
            case .grid:
                return self?.createGridSection()
            default :
                return self?.createListSection()
            }
        }
    }
    
    private func createGridSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(220))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
        group.interItemSpacing = .fixed(10)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        return section
    }
    
    private func createListSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(120))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        return section
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
