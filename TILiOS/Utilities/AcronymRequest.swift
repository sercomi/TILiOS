import Foundation

enum AcronymUserRequestResult {
  case success(User)
  case failure
}

enum CategoryAddResult {
  case success
  case failure
}

struct AcronymRequest {
  let resource: URL
  
  init(acronymID: Int) {
    let resourceString = "http://localhost:8080/api/acronyms/\(acronymID)"
    guard let resourceURL = URL(string: resourceString) else {
      fatalError()
    }
    self.resource = resourceURL
  }
  
  func getUser(completion: @escaping (AcronymUserRequestResult) -> Void) {
    // 1
    let url = resource.appendingPathComponent("user")
    
    // 2
    let dataTask = URLSession.shared.dataTask(with: url) { data, _, _ in
        // 3
        guard let jsonData = data else {
          completion(.failure)
          return
        }
        do {
          // 4
          let user = try JSONDecoder().decode(User.self, from: jsonData)
          completion(.success(user))
        } catch {
          // 5
          completion(.failure)
        }
    }
    // 6
    dataTask.resume()
  }
  
  func getCategories(completion: @escaping (GetResourcesRequest<Category>) -> Void) {
    let url = resource.appendingPathComponent("categories")
    let dataTask = URLSession.shared.dataTask(with: url) { data, _, _ in
        guard let jsonData = data else {
          completion(.failure)
          return
        }
        do {
          let categories = try JSONDecoder().decode([Category].self, from: jsonData)
          completion(.success(categories))
        } catch {
          completion(.failure)
        }
    }
    dataTask.resume()
  }
  
  func update(with updateData: Acronym, completion: @escaping (SaveResult<Acronym>) -> Void) {
    do {
      // 1
      var urlRequest = URLRequest(url: resource)
      urlRequest.httpMethod = "PUT"
      urlRequest.httpBody = try JSONEncoder().encode(updateData)
      urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
      let dataTask = URLSession.shared.dataTask(with: urlRequest) {
          data, response, _ in
          // 2
          guard
            let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
            let jsonData = data else {
              completion(.failure)
              return
          }
          do {
            // 3
            let acronym = try JSONDecoder().decode(Acronym.self, from: jsonData)
            completion(.success(acronym))
          } catch {
            completion(.failure)
          }
      }
      dataTask.resume()
    } catch {
      completion(.failure)
    }
  }
  
  func delete() {
    // 1
    var urlRequest = URLRequest(url: resource)
    urlRequest.httpMethod = "DELETE"
    // 2
    let dataTask = URLSession.shared.dataTask(with: urlRequest)
    dataTask.resume()
  }
  
  func add(category: Category, completion: @escaping (CategoryAddResult) -> Void) {
    // 1
    guard let categoryID = category.id else {
      completion(.failure)
      return
    }
    // 2
    let url = resource.appendingPathComponent("categories").appendingPathComponent("\(categoryID)")
    // 3
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "POST"
    // 4
    let dataTask = URLSession.shared.dataTask(with: urlRequest) {
        _, response, _ in
        // 5
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            completion(.failure)
            return
        }
        // 6
        completion(.success)
    }
    dataTask.resume()
  }
}
