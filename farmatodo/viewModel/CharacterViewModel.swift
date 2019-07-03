//
//  CharacterViewModel.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/1/19.
//  Copyright © 2019 OsSource. All rights reserved.
//

import Foundation

class CharacterViewModel: CharacterViewModelProtocol {
    
    var networkService: NetworkServiceProtocol?
    
    init() {
        print("init :: CharacterViewModel")
        privCurrentCharacter = CharacterModel(id: 0, name: "", thumbnail: ThumbnailModel(path: "", ext: ""), description: "")
    }
    
    private let pageSize = 20
    
    private var privCurrentCharacter: CharacterModel
    var currentCharacter: CharacterModel {
        get { return privCurrentCharacter }
        set { privCurrentCharacter = newValue }
    }
    
    private var privCharacterList = [CharacterModel]()
    var characterList: [CharacterModel] {
        get { return privCharacterList }
    }
    
    private var privComicList = [ComicModel]()
    var comicList: [ComicModel] {
        get { return privComicList }
    }
    
    func getCharacters(
        page: Int,
        complete: @escaping ( ServiceResult<[CharacterModel]?> ) -> Void )  {
        print("init :: getCharacters")
        let offset = page * pageSize
        guard let networkService = networkService else {
            return complete(.Error("Missing network service", 0))
        }
        let baseUrl = networkService.baseUrl
        let hash = networkService.apiKeyTsHash
        //let url = "\(baseUrl)characters?\(hash)&offset=\(offset)&nameStartsWith=Spi"
        let url = "\(baseUrl)characters?\(hash)&offset=\(offset)"
        // TODO: filter: &nameStartsWith=Spi
        networkService.request(
            url: url,
            method: .get,
            parameters: nil
        ) { [weak self] (result) in
            if page == 0 {
                self?.privCharacterList.removeAll()
            }
            switch result {
            case .Success(let json, let statusCode):
                do {
                    print("case .Success :: getCharacters")
                    if let data = json?.data(using: .utf8) {
                        let decoder = JSONDecoder()
                        let characterResponse = try decoder.decode(CharacterResponse.self, from: data)
                        self?.privCharacterList.append(contentsOf: characterResponse.data.results)
                        return complete(.Success(self?.privCharacterList, statusCode))
                    }
                    return complete(.Error("Error parsing data", statusCode))
                } catch {
                    print("error:\(error)")
                    return complete(.Error("Error decoding JSON", statusCode))
                }
            case .Error(let message, let statusCode):
                print("case .Error :: getCharacters")
                return complete(.Error(message, statusCode))
            }
        }
    }
    
    func getCharacterComics(
        page: Int,
        character: Int,
        complete: @escaping ( ServiceResult<[ComicModel]?> ) -> Void )  {
        print("getCharacterComics :: CharacterViewModel")
        let offset = page * pageSize
        guard let networkService = networkService else {
            return complete(.Error("Missing network service", 0))
        }
        let baseUrl = networkService.baseUrl
        let hash = networkService.apiKeyTsHash
        let url = "\(baseUrl)characters/\(character)/comics?\(hash)&offset=\(offset)"
        networkService.request(
            url: url,
            method: .get,
            parameters: nil
        ) { [weak self] (result) in
            if page == 0 {
                self?.privComicList.removeAll()
            }
            switch result {
            case .Success(let json, let statusCode):
                do {
                    print("case .Success getCharacterComics :: CharacterViewModel")
                    if let data = json?.data(using: .utf8) {
                        let decoder = JSONDecoder()
                        let comicResponse = try decoder.decode(ComicResponse.self, from: data)
                        self?.privComicList.append(contentsOf: comicResponse.data.results)
                        return complete(.Success(self?.privComicList, statusCode))
                    }
                    return complete(.Error("Error parsing data", statusCode))
                } catch {
                    print("error:\(error)")
                    return complete(.Error("Error decoding JSON", statusCode))
                }
            case .Error(let message, let statusCode):
                print("case .Error getCharacterComics :: CharacterViewModel")
                return complete(.Error(message, statusCode))
            }
        }
    }
    
}
