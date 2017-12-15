//
//  ProfilePresenter.swift
//  Uai Fotos
//
//  Created by Elifazio Bernardes da Silva on 13/12/2017.
//  Copyright (c) 2017 Uai Fotos. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import SwiftRandom

protocol ProfilePresentationLogic {
  func presentUser(response: Profile.User.Response)
}

class ProfilePresenter: ProfilePresentationLogic {
  weak var viewController: ProfileDisplayLogic?
  
  // MARK: Do something
  
  func presentUser(response: Profile.User.Response) {
    var displayUser: Profile.User.ViewModel.DisplayUser?
    if let loggedUser = response.loggedUser {
        let publications = String(loggedUser.photos?.count ?? 0)
        let followers = String(Int.random())
        let following = String(loggedUser.friends?.count ?? 0)
        let bio = NSMutableAttributedString().bold(loggedUser.name!).normal(
            "\n\(loggedUser.title!)\n\(loggedUser.email!)\n\(Randoms.randomFakeConversation())")
        let photos: [URL] = loggedUser.photos?.map({ (photo) -> URL in
            return photo.imageUrl
        }) ?? []
        
        displayUser = Profile.User.ViewModel.DisplayUser(name: loggedUser.name!, avatar: loggedUser.avatarUrl, publications: publications, followers: followers, following: following, bio: bio, photos: photos)
    }

    let viewModel = Profile.User.ViewModel(displayUser: displayUser)
    viewController?.displayUser(viewModel: viewModel)
  }
}