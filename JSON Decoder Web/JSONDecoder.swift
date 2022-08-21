//
//  ContentView.swift
//  JSONDecoding
//
//  Created by Ari Reitman on 8/20/22.
//

import Combine

class DownloadWithCombineViewModel: ObservableObject {
    @Published var posts: [PostModel] = []
    var cancellables = Set<AnyCancellable>()
    
    init() {
        getPosts()
    }
    
    //Combine discussion
    /*
    // 1. sign up for monthly subscription for package to be delivered
    // 2. the company would make the package behind the scene
    // 3. recieve the package at your front door
    // 4. make sure the box isn't damaged
    // 5. open and make sure the item is correct
    // 6. use the item!!!!
    // 7. cancellable at any time!!
    
    
    // 1. create the publisher
    // 2. subscribe publisher on background thread
    // 3. recieve on main thread
    // 4. tryMap (check that the data is good)
    // 5. decode (decode data into post model)
    // 6. sink (put the item into the app)
    // 7. store (cancel subscription if needed)
     */
    
    func getPosts() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { return }
        
        URLSession.shared.dataTaskPublisher(for: url) //create the publisher
            .subscribe(on: DispatchQueue.global(qos: .background)) //set on the background thread for performance
            .receive(on: DispatchQueue.main) //recieve on the main thread
            .tryMap(handleOutput)
            .decode(type: [PostModel].self, decoder: JSONDecoder()) //decode the data
            .sink{ (completion) in
                switch completion {
                case .finished:
                    print("finished")
                case .failure(let error):
                    print("Error: \(error)")
                }
            } receiveValue: { [weak self] (returnedPosts) in
                self?.posts = returnedPosts
            }
            .store(in: &cancellables)
    }
    
    func handleOutput(output: URLSession.DataTaskPublisher.Output) throws -> Data {
        guard let response = output.response as? HTTPURLResponse,
              response.statusCode >= 200 && response.statusCode < 300 else {
            throw URLError(.badServerResponse)
        }
        return output.data
    }
}

