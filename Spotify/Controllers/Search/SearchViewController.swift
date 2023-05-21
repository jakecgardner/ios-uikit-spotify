//
//  SearchViewController.swift
//  Spotify
//
//  Created by jake on 2/15/23.
//

import SafariServices
import UIKit

class SearchViewController: UIViewController {
    
    private let searchController: UISearchController = {
        let resultsVc = SearchResultsViewController()
        let search = UISearchController(searchResultsController: resultsVc)
        search.searchBar.placeholder = "Songs, Artists, Albums"
        search.searchBar.searchBarStyle = .minimal
        search.definesPresentationContext = true
        return search
    }()
    
    private let collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _ in
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.5),
                    heightDimension: .fractionalHeight(1)
                )
            )
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(150)
                ),
                subitems: [item, item]
            )
            
            group.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 10)
            
            return NSCollectionLayoutSection(group: group)
        })
    )
    
    private var categories: [Category] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        
        configureCollectionView()
        
        APIService.shared.getCategories { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self?.categories = items
                    self?.collectionView.reloadData()
                case .failure:
                    break
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
    }
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        let category = categories[indexPath.row]
        cell.configure(with: CategoryCollectionCellViewModel(
            name: category.name,
            artwork: URL(string: category.icons.first?.url ?? "")
        ))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        HapticsService.shared.vibrateSelect()
        
        collectionView.deselectItem(at: indexPath, animated: true)
        let category = categories[indexPath.row]
        let categoryVc = CategoryViewController(category: category)
        categoryVc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(categoryVc, animated: true)
    }
}

extension SearchViewController: UISearchResultsUpdating, UISearchBarDelegate, SearchResultsViewControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text,
              let resultsController = searchController.searchResultsController as? SearchResultsViewController,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }

        resultsController.delegate = self
        
        APIService.shared.search(with: query) { result in
            switch result {
            case .success(let results):
                resultsController.update(with: results)
            case .failure:
                break
            }
        }
    }
    
    func didTapResult(_ result: SearchResult) {
        var vc = UIViewController()
        
        switch result {
        case .artist(let model):
            guard let url = URL(string: model.externalUrls["spotify"] ?? "") else {
                return
            }
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
            
        case .album(let model):
            vc = AlbumViewController(album: model)
            
        case .track(let model):
            PlaybackPresenter.shared.startPlayback(from: self, track: model)
            
        case .playlist(let model):
            vc = PlaylistViewController(playlist: model)
        }
        
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
