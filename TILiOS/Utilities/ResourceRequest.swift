import Foundation

enum GetResourcesRequest<ResourceType> {
  case success([ResourceType])
  case failure
}

enum SaveResult<ResourceType> {
  case success(ResourceType)
  case failure
}

struct ResourceRequest<ResourceType> where ResourceType: Codable {
  let baseURL = "http://localhost:8080/api/"
  let resourceURL: URL

  init(resourcePath: String) {
    guard let resourceURL = URL(string: baseURL) else {
      fatalError()
    }
    
    self.resourceURL = resourceURL.appendingPathComponent(resourcePath)
  }
  
  func getAll(completion: @escaping (GetResourcesRequest<ResourceType>) -> Void) {
      // 5
      let dataTask = URLSession.shared
        .dataTask(with: resourceURL) {
          data, _, _ in
          // 6
          guard let jsonData = data else {
            completion(.failure)
            return
          }
          do {
            // 7
            let resources
              = try JSONDecoder().decode([ResourceType].self,
                                         from: jsonData)
            // 8
            completion(.success(resources))
          } catch {
            // 9
            completion(.failure)
          }
      }
      // 10
      dataTask.resume()
    }
  
  func save(_ resourceToSave: ResourceType, completion: @escaping (SaveResult<ResourceType>) -> Void) {
    do {
      // 2
      var urlRequest = URLRequest(url: resourceURL)
      // 3
      urlRequest.httpMethod = "POST"
      // 4
      urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
      // 5
      urlRequest.httpBody = try JSONEncoder().encode(resourceToSave)
      // 6
      let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
          // 7
          guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let jsonData = data else {
              completion(.failure)
              return
            }
          
          do {
            // 8
            let resource =
              try JSONDecoder().decode(ResourceType.self,
                                       from: jsonData)
            completion(.success(resource))
          } catch {
            // 9
            completion(.failure)
          }
      }
      // 10
      dataTask.resume()
      // 11
    } catch {
      completion(.failure)
    }
  }
}
