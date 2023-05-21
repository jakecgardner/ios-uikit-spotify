//
//  SearchResultsViewController.swift
//  Spotify
//
//  Created by jake on 3/7/23.
//

import UIKit

struct SearchSection {
    let title: String
    let results: [SearchResult]
}

protocol SearchResultsViewControllerDelegate: AnyObject {
    func didTapResult(_ result: SearchResult)
}

class SearchResultsViewController: UIViewController {

    weak var delegate: SearchResultsViewControllerDelegate?
    
    private var sections: [SearchSection] = []
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(SearchResultsTableViewCell.self, forCellReuseIdentifier: SearchResultsTableViewCell.identifier)
        table.register(SearchResultsSubtitleTableViewCell.self, forCellReuseIdentifier: SearchResultsSubtitleTableViewCell.identifier)
        table.isHidden = true
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        configureTableView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func update(with results: [SearchResult]) {
        let artists = results.filter({ switch $0 { case .artist: return true; default: return false } })
        let albums = results.filter({ switch $0 { case .album: return true; default: return false } })
        let tracks = results.filter({ switch $0 { case .track: return true; default: return false } })
        let playlists = results.filter({ switch $0 { case .playlist: return true; default: return false } })
        
        DispatchQueue.main.async {
            self.sections = [
                SearchSection(title: "Artists", results: artists),
                SearchSection(title: "Albums", results: albums),
                SearchSection(title: "Tracks", results: tracks),
                SearchSection(title: "Playlists", results: playlists)
            ]
            self.tableView.isHidden = results.isEmpty
            self.tableView.reloadData()
        }
    }
}

extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = sections[indexPath.section].results[indexPath.row]
        
        
        switch result {
        case .artist(let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultsTableViewCell.identifier, for: indexPath) as? SearchResultsTableViewCell else {
                return UITableViewCell()
            }
            let viewModel = SearchResultsTableViewCellViewModel(title: model.name, imageUrl: URL(string: model.images?.first?.url ?? ""))
            cell.configure(with: viewModel)
            return cell
        case .album(let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultsSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultsSubtitleTableViewCell else {
                return UITableViewCell()
            }
            let viewModel = SearchResultsSubtitleTableViewCellViewModel(
                title: model.name,
                description: model.artists.first?.name ?? "-",
                imageUrl: URL(string: model.images.first?.url ?? ""))
            cell.configure(with: viewModel)
            return cell
        case .track(let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultsSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultsSubtitleTableViewCell else {
                return UITableViewCell()
            }
            let viewModel = SearchResultsSubtitleTableViewCellViewModel(
                title: model.name,
                description: model.artists.first?.name ?? "-",
                imageUrl: URL(string: model.album?.images.first?.url ?? ""))
            cell.configure(with: viewModel)
            return cell
        case .playlist(let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultsSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultsSubtitleTableViewCell else {
                return UITableViewCell()
            }
            let viewModel = SearchResultsSubtitleTableViewCellViewModel(
                title: model.name,
                description: model.description,
                imageUrl: URL(string: model.images.first?.url ?? ""))
            cell.configure(with: viewModel)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].results.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let result = sections[indexPath.section].results[indexPath.row]
        delegate?.didTapResult(result)
    }
}
