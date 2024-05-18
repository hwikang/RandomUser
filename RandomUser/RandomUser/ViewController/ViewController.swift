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

class ViewController: UIViewController {
    private let viewModel: ViewModel
    private let refreshTrigger = PublishRelay<Void>()
    private let fetchMoreTrigger = PublishRelay<Void>()
    private let deleteUserTrigger = PublishRelay<[String]>()
    private let deleteUserList = BehaviorRelay<[String]>(value: [])
    private let viewMode = BehaviorRelay<ViewMode>(value: .view)
    private let layoutType = BehaviorRelay<Section>(value: .grid)
    private let disposeBag = DisposeBag()
    
    private let tabButtonView = TabButtonView(typeList: [.male, .female])
    private lazy var pageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        return pageViewController
    }()
    private lazy var pages: [UIViewController] = [maleViewController, femaleViewController]
    private let maleViewController = UserListViewController()
    private let femaleViewController = UserListViewController()
    
    private let floatingButton = FloatingButton(title: "View 전환")
    private let deleteViewModeButton = {
        let button = UIButton()
        button.setTitle("삭제", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.setTitle("취소", for: .selected)
        button.setTitleColor(.systemBlue, for: .selected)
        return button
    }()
    private let deleteButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.isHidden = true
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
        tabButtonView.select(index: 0)
        pageViewController.setViewControllers([maleViewController], direction: .forward, animated: true, completion: nil)
        refreshTrigger.accept(())
    }
    
    private func setUI() {
        title = "Random Users"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: deleteViewModeButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: deleteButton)
        view.addSubview(tabButtonView)
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        view.addSubview(floatingButton)
        
        setConstraints()
    }
    
    private func bindView() {
        tabButtonView.selectedType.bind { [weak self] type in
            guard let self = self else { return }
            switch type {
            case .male:
                pageViewController.setViewControllers([pages[0]], direction: .reverse, animated: true, completion: nil)
            case .female:
                pageViewController.setViewControllers([pages[1]], direction: .forward, animated: true, completion: nil)

            }
        }.disposed(by: disposeBag)

        floatingButton.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            switch layoutType.value {
            case .grid:
                layoutType.accept(.list)
            case .list:
                layoutType.accept(.grid)
            }
        }.disposed(by: disposeBag)
        deleteViewModeButton.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            switch viewMode.value {
            case .view:
                viewMode.accept(.delete)
            case .delete:
                viewMode.accept(.view)
            }
        }.disposed(by: disposeBag)
       
        viewMode.bind { [weak self] viewMode in
            guard let self = self else { return }
            switch viewMode {
            case .delete:
                deleteViewModeButton.isSelected = true
                deleteButton.isHidden = false
            case .view:
                deleteViewModeButton.isSelected = false
                deleteButton.isHidden = true
                deleteUserList.accept([])
            }
        }.disposed(by: disposeBag)
        
        deleteButton.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            deleteUserTrigger.accept(deleteUserList.value)
            deleteUserList.accept([])
            viewMode.accept(.view)
        }.disposed(by: disposeBag)
        
        Observable.merge(maleViewController.selectedUser, femaleViewController.selectedUser)
            .bind { [weak self] selectedUser in
                guard let self = self else { return }
                switch viewMode.value {
                case .view:
                    pushImageDetailVC(imageURL: selectedUser.picture.largeURL)
                case .delete:
                    selectDeleteUser(selectedUser: selectedUser)
                }
            }.disposed(by: disposeBag)

        Observable.merge(maleViewController.refreshControl.rx.controlEvent(.valueChanged).asObservable(),
                         femaleViewController.refreshControl.rx.controlEvent(.valueChanged).asObservable())
            .bind(to: refreshTrigger)
            .disposed(by: disposeBag)
        
        Observable.merge(maleViewController.fetchMoreUser, femaleViewController.fetchMoreUser)
            .debounce(.milliseconds(200), scheduler: MainScheduler.instance)
            .bind(to: fetchMoreTrigger)
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        let input = ViewModel.Input(refresh: refreshTrigger.asObservable(), fetchMore: fetchMoreTrigger.asObservable(), deleteUser: deleteUserTrigger.asObservable())
        let output = viewModel.transform(input: input)
 
        output.loading
            .observe(on: MainScheduler.instance)
            .bind { [weak self] isLoading in
                guard let visibleViewController = self?.pageViewController.viewControllers?.first,
                      let index = self?.pages.firstIndex(of: visibleViewController) else { return }
                if index == 0 {
                    self?.maleViewController.refreshControl.rx.isRefreshing.onNext(isLoading)
                } else {
                    self?.femaleViewController.refreshControl.rx.isRefreshing.onNext(isLoading)
                }
            }.disposed(by: disposeBag)
            
        output.error
            .observe(on: MainScheduler.instance)
            .bind { [weak self] error in
                self?.presentErrorAlert(error: error)
            }.disposed(by: disposeBag)
        
        Observable.combineLatest(deleteUserList, layoutType, output.maleList, output.femaleList)
            .observe(on: MainScheduler.instance)
            .bind { [weak self] deleteUserList, layoutType, maleList, femaleList in
                self?.maleViewController.applyData(selectedUserList: deleteUserList, section: layoutType, userList: maleList)
                self?.femaleViewController.applyData(selectedUserList: deleteUserList, section: layoutType, userList: femaleList)
            }.disposed(by: disposeBag)
    }
    
    private func pushImageDetailVC(imageURL: URL?) {
        let imageDetailVC = ImageDetailViewController(imageURL: imageURL)
        navigationController?.pushViewController(imageDetailVC, animated: true)
    }
    
    private func selectDeleteUser(selectedUser: User) {
        var deleteUserList = deleteUserList.value
        if deleteUserList.contains(where: { $0 == selectedUser.uuid }) {
            deleteUserList.removeAll { $0 == selectedUser.uuid }
        } else {
            deleteUserList.append(selectedUser.uuid)
        }
        self.deleteUserList.accept(deleteUserList)
    }
    
    private func presentErrorAlert(error: Error) {
        let alert = UIAlertController(title: "에러", message: "뉴스 불러오기에 실패 하였습니다. 다시 시도해 주세요\n\(error.localizedDescription)", preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: UIAlertAction.Style.default)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    private func setConstraints() {
        tabButtonView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(60)
        }
        pageViewController.view.snp.makeConstraints { make in
            make.top.equalTo(tabButtonView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        floatingButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.trailing.equalToSuperview().inset(20)
            make.width.equalTo(120)
            make.height.equalTo(44)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
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
            tabButtonView.select(index: index)
        }
    }
    
}
