/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

class AcronymsTableViewController: UITableViewController {

  // MARK: - Properties
  var acronyms: [Acronym] = []
  let acronymsRequest = ResourceRequest<Acronym>(resourcePath: "acronyms")

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView = UIView()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    refresh(nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // 1
    if segue.identifier == "AcronymsToAcronymDetail" {
      // 2
      guard let destination = segue.destination as? AcronymDetailTableViewController, let indexPath = tableView.indexPathForSelectedRow else {
          return
      }
      
      // 3
      destination.acronym = acronyms[indexPath.row]
    }
  }

  // MARK: - IBActions
  @IBAction func refresh(_ sender: UIRefreshControl?) {

    // 1
    acronymsRequest.getAll { [weak self] acronymResult in
      // 2
      DispatchQueue.main.async {
        sender?.endRefreshing()
      }
      
      switch acronymResult {
      // 3
      case .failure:
      ErrorPresenter.showError(message: "There was an error getting the acronyms", on: self)
      // 4
      case .success(let acronyms):
        DispatchQueue.main.async { [weak self] in
          self?.acronyms = acronyms
          self?.tableView.reloadData()
        }
      }
    }
  }
}

// MARK: - UITableViewDataSource
extension AcronymsTableViewController {

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return acronyms.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "AcronymCell", for: indexPath)
    
    let acronym = acronyms[indexPath.row]
    cell.textLabel?.text = acronym.short
    cell.detailTextLabel?.text = acronym.long
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if let id = acronyms[indexPath.row].id {
      // 1
      let acronymDetailRequester = AcronymRequest(acronymID: id)
      acronymDetailRequester.delete()
    }
    
    // 2
    acronyms.remove(at: indexPath.row)
    // 3
    tableView.deleteRows(at: [indexPath], with: .automatic)
  }
}
