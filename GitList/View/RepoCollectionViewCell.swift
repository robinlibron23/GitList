//
//  CollectionViewCell.swift
//  GitList
//
//  Created by Robin Thomas on 8/2/18.
//  Copyright © 2018 TestOrg. All rights reserved.
//

import Foundation
import UIKit

final class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
    
    func populateData(repo: RepoModel) {
        backgroundColor = UIColor.cyan
        label.text = "Name: \(repo.name)\nDescription: \(repo.description) \nCreatedAt: \(repo.createdAt) \nLicense: \(repo.license)"
    }
}
