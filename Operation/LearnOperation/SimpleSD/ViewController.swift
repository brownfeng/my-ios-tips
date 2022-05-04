//
//  ViewController.swift
//  SimpleSD
//
//  Created by brown on 2022/5/3.
//

import UIKit

class ViewController: UIViewController {
    var urls: [(title: String, url: String)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadJson()
        print("\(self.urls)")
    }

    func loadJson() {
        let inputUrl = Bundle.main.url(forResource: "input", withExtension: "json")!
        do {
            let data = try Data(contentsOf: inputUrl)
            if let jsonDict = try JSONSerialization.jsonObject(with: data) as? [[String: String]] {
                self.urls = jsonDict.map { ($0.first!.key, $0.first!.value) }
            }
        } catch {}
    }
}
