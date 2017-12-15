//
//  SearchViewController.swift
//  Uai Fotos
//
//  Created by Elifazio Bernardes da Silva on 12/12/2017.
//  Copyright (c) 2017 Uai Fotos. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import SwiftyAvatar

protocol SearchDisplayLogic: class {
    func displayFriends(viewModel: Search.Friends.ViewModel)
}

class SearchViewController: UIViewController, SearchDisplayLogic {
    var interactor: SearchBusinessLogic?
    var router: (NSObjectProtocol & SearchRoutingLogic & SearchDataPassing)?
    let searchController = UISearchController(searchResultsController: nil)
    
    var displayedFriends: [Search.Friends.ViewModel.DisplayFriend] = []
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = SearchInteractor()
        let presenter = SearchPresenter()
        let router = SearchRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSearchBarController()
        self.interactor?.getAllFriends()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.navigationController?.navigationBar.topItem?.title = "Uai Fotos"
        
        // Cria um botão a esquerda
        let leftButton = UIBarButtonItem(image: #imageLiteral(resourceName: "compact_camera"), style: .plain, target: nil, action: nil)
        self.tabBarController?.navigationItem.leftBarButtonItem = leftButton
        
        // Cria um botão a direita
        let rightButton = UIBarButtonItem(image: #imageLiteral(resourceName: "rocket"), style: .plain, target: nil, action: nil)
        self.tabBarController?.navigationItem.rightBarButtonItem = rightButton
    }
    
    // MARK: tableview
    @IBOutlet weak var tableView: UITableView!
    
    func createSearchBarController() {
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "Pesquisar amigos"
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.definesPresentationContext = true
    }
    
    // MARK: filter content
    func filterContentForSearchText() {
        let request = Search.Friends.Request(searchText: self.searchController.searchBar.text!)
        interactor?.filterFriendsForSearchText(request: request)
    }
    
    func displayFriends(viewModel: Search.Friends.ViewModel) {
        self.displayedFriends = viewModel.displayedFriends
        self.tableView.reloadData()
    }
    
    // MARK: - Private instance methods
    func searchBarIsEmpty() -> Bool {
        return self.searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return self.searchController.isActive && !self.searchBarIsEmpty()
    }
}

extension SearchViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        if self.searchBarIsEmpty() {
            self.interactor?.getAllFriends()
        } else {
            self.filterContentForSearchText()
        }
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    static let filteredFriendCellIdentifier = "filteredFriendCell"
    
    // MARK: - UITableViewDataSource, UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayedFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: SearchViewController.filteredFriendCellIdentifier, for: indexPath)
        
        let friend = self.displayedFriends[indexPath.row]
        
        cell.textLabel?.text = friend.name
        cell.detailTextLabel?.text = friend.title
        cell.imageView?.kf.indicatorType = .activity
        cell.imageView?.kf.setImage(with: friend.avatarUrl)
        
        cell.isHeroEnabled = true
        cell.heroModifiers = [.fade, .scale(0.5)]
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        TipInCellAnimator.fadeIn(cell: cell.contentView)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.router?.routeToProfile(segue: nil)
        self.searchController.dismiss(animated: true, completion: nil)
    }
}
