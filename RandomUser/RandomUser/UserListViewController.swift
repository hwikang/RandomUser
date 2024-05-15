//
//  UserListViewController.swift
//  RandomUser
//
//  Created by paytalab on 5/15/24.
//

 
import UIKit
import SnapKit
import RxSwift

enum Section {
    case grid
    case list
}

enum Item: Hashable {
    case grid(user: User, isSelected: Bool = false)
    case list(user: User, isSelected: Bool = false)
}

class UserListViewController: UIViewController, UICollectionViewDelegate {
    private let disposeBag = DisposeBag()
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>?
    public lazy var selectedUser: Observable<User> = collectionView.rx.itemSelected.compactMap { [weak self] indexPath in
        let item = self?.dataSource?.itemIdentifier(for: indexPath)
        switch item {
        case let .grid(user, _), let .list(user, _):
            return user
        default: return nil
        }

    }

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
    
    
    public func applyData(selectedUserList: [String], section: Section, userList: [User]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section,Item>()
        var items: [Item]
        switch section {
        case .grid:
            items = userList.map { user in
                Item.grid(user: user, isSelected: selectedUserList.contains(where: { $0 == user.uuid }))
            }
        case .list:
            items = userList.map { user in
                Item.list(user: user, isSelected: selectedUserList.contains(where: { $0 == user.uuid }))
            }
        }
        snapshot.appendSections([section])
        snapshot.appendItems(items, toSection: section)
        dataSource?.apply(snapshot)

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
            
            if case let .grid(user, isSelected) = item {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridCollectionViewCell.id, for: indexPath) as? GridCollectionViewCell
                cell?.apply(user: user, isSelected: isSelected)
                return cell
            } else if case let .list(user, isSelected) = item {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListCollectionViewCell.id, for: indexPath) as? ListCollectionViewCell
                cell?.apply(user: user, isSelected: isSelected)
                return cell
            }
            
            return nil
        }
        
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            let section = self?.dataSource?.snapshot().sectionIdentifiers[sectionIndex]
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
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
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
