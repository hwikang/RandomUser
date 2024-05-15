//
//  ViewModel.swift
//  RandomUser
//
//  Created by paytalab on 5/15/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ViewModel {
    private let network: UserNetwork
    private let page = BehaviorRelay<Int>(value: 1)
    private let userList = BehaviorRelay<[User]>(value: [])
    private let disposeBag = DisposeBag()
    struct Input {
        public let refresh: Observable<Void>
        public let fetchMore: Observable<Void>
        public let deleteUser: Observable<[String]>
    }
    
    struct Output {
        public let maleList: Observable<[User]>
        public let femaleList: Observable<[User]>
    }
    
    init(network: UserNetwork) {
        self.network = network
        Task {
            await getUsers(page: 1)
        }
    }
    
    public func transform(input: Input) -> Output {
        input.fetchMore.bind { [weak self] in
            guard let self = self else { return }
            Task {
                await self.getUsers(page: self.page.value + 1)
            }
           
        }.disposed(by: disposeBag)
        input.refresh.bind { [weak self] in
            guard let self = self else { return }
            self.page.accept(1)
            self.userList.accept([])
            Task {
                await self.getUsers(page: self.page.value)
            }
        }.disposed(by: disposeBag)
        input.deleteUser.bind { [weak self] deleteUserList in
            guard let self = self else { return }

            var userList = userList.value
            userList.removeAll { user in
                deleteUserList.contains { user.uuid == $0 }
            }
            self.userList.accept(userList)
        }.disposed(by: disposeBag)
        
        let maleList = userList.map { userList in
             return userList.filter { $0.gender == .male }
        }
        let femaleList = userList.map { userList in
             return userList.filter { $0.gender == .female }
        }
        return Output(maleList: maleList, femaleList: femaleList)
    }
    
    private func getUsers(page: Int) async {
        let result = await network.getUsers(page: page, results: 30)
        switch result {
        case .success(let fetchedUserList):
            userList.accept(fetchedUserList)
        case .failure(let error):
            //TODO: eror
            print(error)
        }
    }
}
