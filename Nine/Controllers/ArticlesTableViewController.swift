//
//  ArticlesTableViewController.swift
//  Nine
//
//  Created by abc on 7/5/22.
//

import UIKit

class ArticlesTableViewController: UITableViewController {
    
    private var dataSource: UITableViewDiffableDataSource<Section, Item>!
    private var viewModel: ArticlesViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect the diffable data source to the table view by passing it into the initializer alongside a cell provider
        dataSource = UITableViewDiffableDataSource<Section, Item>(tableView: tableView) {
            [unowned self] (tableView: UITableView, indexPath: IndexPath, item: Item) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: ArticleTableViewCell.identifier, for: indexPath) as! ArticleTableViewCell
            
            // Configure the cell with the current item
            cell.configureView(headline: item.headline, abstract: item.abstract, byLine: item.byLine, image: item.image)
            
            // If there's a thumbnail image for the article, load it asynchronously and cache it
            self.viewModel.loadItemImage(item)
            
            return cell
        }
        dataSource.defaultRowAnimation = .fade
        
        // Load the cell from the nib by registering it with the tableView
        tableView.register(ArticleTableViewCell.nib, forCellReuseIdentifier: ArticleTableViewCell.identifier)
        
        // Create a view model and kick off initial data loading
        viewModel = ArticlesViewModel(delegate: self)
        viewModel.loadItems()
    }
    
}

// MARK: - ArticlesViewModelDelegate

extension ArticlesTableViewController: ArticlesViewModelDelegate {
    
    func viewStateChanged(_ viewState: ArticlesViewModel.ViewState) {
        if let reloadItemIndex = viewState.reloadItemIndex {
            self.dataSource.reloadItem(viewState.items[reloadItemIndex])
        } else {
            self.navigationItem.title = viewState.title
            self.dataSource.loadItems(viewState.items)
        }
    }
    
    func handleError(_ error: Error) {
        print("Error fetching articles: \(String(describing: error))")
    }
}

// MARK: - UITableViewDelegate

extension ArticlesTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Create the detail view controller programmatically
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        let vc = ArticlesDetailViewController.initialize(detailItem: item)
        // Use `showDetailViewController` rather then directly pushing onto the navigation controller
        // to futureproof an upgrade to UISplitViewController
        showDetailViewController(vc, sender: self)
    }
}
