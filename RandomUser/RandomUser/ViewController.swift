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

class ViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    private let disposeBag = DisposeBag()
    private let tabButtonStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()
    private let maleTabButton2 = TabButton(title: "남자")
    private let maleTabButton = TabButton(title: "남자")
    private let femaleTabButton = TabButton(title: "여자")
    lazy var pageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        return pageViewController
    }()
    lazy var pages: [UIViewController] = {
        let pages = [maleViewController, femaleViewController]
        return pages
    }()
    let maleViewController = MaleViewController()
    let femaleViewController = FemaleViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        bindView()
        maleTabButton.isSelected = true
    }
    
    private func setUI() {
        title = "Random Users"
        view.addSubview(tabButtonStackView)
        tabButtonStackView.addArrangedSubview(maleTabButton)
        tabButtonStackView.addArrangedSubview(femaleTabButton)
        tabButtonStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(60)
        }
        setPageView()
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
    }
    
    private func setPageView() {
        if let firstViewController = pages.first {
            pageViewController.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
                
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        pageViewController.view.snp.makeConstraints { make in
            make.top.equalTo(tabButtonStackView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
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
}

class MaleViewController: UIViewController {
    override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .red
            self.title = "MaleViewController"
        }
}

class FemaleViewController: UIViewController {
    override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .blue
            self.title = "FemaleViewController"
        }
}
