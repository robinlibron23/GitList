//
//  RepoListingViewController.swift
//  GitList
//
//  Created by Robin Thomas on 8/2/18.
//  Copyright © 2018 TestOrg. All rights reserved.
//

import UIKit

final class RepoListingViewController: UIViewController {
    // Outlets
    @IBOutlet weak private var collectionView: UICollectionView!
    @IBOutlet weak private var textField: UITextField!
    // Variables
    private var isGridViewSelected = true
    private let numberOfCellsPerRow = 2
    private var gitRepos = [RepoModel]()
    private let reuseIdentifier = "cell"
    private lazy var viewModel = RepoListingViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
    }

    func setUpCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = UICollectionViewFlowLayout()
        //        layout.scrollDirection = .vertical //.horizontal
        //        layout.itemSize = cellSize
        //        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        layout.minimumLineSpacing = 1.0
        layout.minimumInteritemSpacing = 1.0
        collectionView.setCollectionViewLayout(layout, animated: true)
    }

    // MARK: Actions
    @IBAction private func goButtonTap(_ sender: UIButton) {
        viewModel.fetchInitialRepos(for: textField.text ?? "") { [weak self] repos in
            self?.gitRepos = repos
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }

    @IBAction private func segmentedControlDidChangeValue(_ sender: UISegmentedControl) {
        isGridViewSelected = sender.selectedSegmentIndex == 0
        collectionView.reloadData()
    }
}

extension RepoListingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewFrameHeight = view.frame.height
        let viewFrameWidth = view.frame.width
        var cellSize = CGSize(width: 120, height: 120)

        if isGridViewSelected {
            if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                let horizontalSpacing = flowLayout.scrollDirection == .vertical ? flowLayout.minimumInteritemSpacing : flowLayout.minimumLineSpacing
                let totalPaddingWidth = CGFloat(max(0, numberOfCellsPerRow - 1)) * horizontalSpacing

                let cellWidth = (view.frame.width - totalPaddingWidth) / CGFloat(numberOfCellsPerRow)
                cellSize = CGSize(width: cellWidth, height: viewFrameHeight / 3)
            }
        } else {
            cellSize = CGSize(width: viewFrameWidth, height: 120)
        }
        return cellSize
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("indexPath.row: \(indexPath.row)")
        print("gitRepos.count-1: \(gitRepos.count - 1)")
        if indexPath.row == gitRepos.count - 1 {
            viewModel.fetchMoreRepos(for: textField.text ?? "") { [weak self] repos in
                self?.gitRepos = repos
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
        }
    }
}

extension RepoListingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gitRepos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! CollectionViewCell
        cell.label.text = "Name: \(self.gitRepos[indexPath.item].name)\nDescription: \(self.gitRepos[indexPath.item].description) \nCreatedAt: \(self.gitRepos[indexPath.item].createdAt) \nLicense: \(self.gitRepos[indexPath.item].license)"
        cell.backgroundColor = UIColor.cyan

        return cell
    }
}

extension RepoListingViewController: UICollectionViewDelegate {

}
