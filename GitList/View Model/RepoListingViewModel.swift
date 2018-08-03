//
//  RepoListingViewModel.swift
//  GitList
//
//  Created by Thomas, Robin on 8/3/18.
//  Copyright © 2018 TestOrg. All rights reserved.
//

import Foundation

typealias CompletionClosure = ([RepoModel]) -> Void
final class RepoListingViewModel {
    private var repos:[RepoModel] = []
    private var loadMoreCounter = 1

    func fetchMoreRepos(for project:String, completion: @escaping CompletionClosure) {
        if repos.count >= loadMoreCounter * 10 {
            loadMoreCounter += 1
            makeAPICall(name: project, page: loadMoreCounter, completion: completion)
        }
    }

    func fetchInitialRepos(for project:String, completion: @escaping CompletionClosure) {
        repos = [RepoModel]()
        
        makeAPICall(name: project, page: 1, completion: completion)
    }

    func makeAPICall(name: String, page: Int, completion: @escaping CompletionClosure) {
        let endPoint = "https://api.github.com/users/\(name)/repos?page=\(page)&per_page=10"
        let session = URLSession.shared

        guard let url = URL(string: endPoint) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = URLRequest(url: url)

        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in

            // check for any errors
            guard error == nil, let responseData = data else {
                print(error!)
                return
            }

            self.parseAPIResponse(responseData: responseData, completion)
        }
        task.resume()
    }

    func parseAPIResponse(responseData: Data, _ completion: @escaping CompletionClosure) {
        var name = ""
        var description = ""
        var createdAt = ""
        var licenseName = ""

        do {
            guard let responseData = try JSONSerialization.jsonObject(with: responseData, options: [])
                as? [Any] else {
                    print("error trying to convert data to JSON")
                    return
            }

            for repo in responseData {
                guard let repoDict = repo as? Dictionary<String, Any> else { return }

                if let nameFromAPI = repoDict["name"] as? String {
                    name = nameFromAPI
                }
                if let descriptionFromAPI = repoDict["description"] as? String {
                    description = descriptionFromAPI
                }
                if let createdAtFromAPI = repoDict["created_at"] as? String {
                    createdAt = createdAtFromAPI
                }
                if let license = repoDict["license"] as? Dictionary<String, Any> {
                    if let licenseFromAPI =  license["name"] as? String {
                        licenseName = licenseFromAPI
                    }
                }
                repos.append(RepoModel(name: name, description: description, createdAt: createdAt, license: licenseName))
            }
            completion(repos)
        } catch  {
            print("error trying to convert data to JSON")
            return
        }
    }
}
