//
//  main.swift
//  PokemonListGenerator
//
//  Created by Haoxin Li on 7/1/18.
//  Copyright © 2018 Haoxin Li. All rights reserved.
//
//  Usage: save the CSV console output to a file

import Foundation

extension URLSession {
    
    // Original code: https://stackoverflow.com/questions/26784315/can-i-somehow-do-a-synchronous-http-request-via-nsurlsession-in-swift
    func synchronousDataTask(with url: URL) -> (Data?, URLResponse?, Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        let semaphore = DispatchSemaphore(value: 0)
        let dataTask = self.dataTask(with: url) {
            data = $0
            response = $1
            error = $2
            semaphore.signal()
        }
        dataTask.resume()
        _ = semaphore.wait(timeout: .distantFuture)
        return (data, response, error)
    }
}

print("Start fetching the list of pokemons")

let urlString = "https://pokeapi.co/api/v2/pokemon?limit=802" // so far there are 802 pokemons on PokeAPI record
guard let url = URL(string: urlString) else {
    fatalError("Invalid URL \(urlString)")
}

let (data, response, error) = URLSession.shared.synchronousDataTask(with: url)
if let e = error {
    fatalError(e.localizedDescription)
}

guard let jsonData = data else {
    fatalError("Failed to obtain data")
}

let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: [])
guard let jsonDict = jsonObject as? [String: Any], let results = jsonDict["results"] as? [[String: Any]] else {
    fatalError("Failed to convert JSON data")
}

for (i, entry) in results.enumerated() {
    guard
        let name = (entry["name"] as? String)?.capitalized,
        let urlString = entry["url"] as? String,
        let url = URL(string: urlString),
        let pokemonNumber = Int(url.lastPathComponent),
        pokemonNumber == i + 1 else { // pokemon number starts from 1, not 0
        fatalError("Invalid information for entry \(entry)")
    }
    print("\(pokemonNumber),\(name)")
}

print("Job done")
