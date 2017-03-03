/*
 * PublicationCocoa Copyright (C) 2017 Fatih.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import WebKit

import RxSwift
import MVPCocoa
import Material

class NavigationViewControllerPresenterImp: AbstractPresenter<NavigationViewController>,
	NavigationViewControllerPresenter, LogType,
	WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
	
	let SCHEME_HTTP		= "http";
	let SCHEME_HTTPS	= "https";
	let SCHEME_FILE		= "file";
	
	var udelegate: WKUIDelegate {
		get {
			return self;
		}
	}
	
	var ndelegate: WKNavigationDelegate {
		get {
			return self;
		}
	}
	
	var jdelegate: WKScriptMessageHandler {
		get {
			return self;
		}
	}
	
	var file: URL?;
	var contents: [String]?;
	var displayState: Bool = false;
	
	var positions: [Int: CGFloat] = [:];
	let width2 = Screen.width / 2;
	let dispose = DisposeBag();
	
	override func viewDidLoad() {
		super.viewDidLoad();
		if let file = file {
			view.load(url: file);
		}
		BusManager.register(next: { [weak weakSelf = self] evt in
			if let event = evt as? PageSelectedByIndex {
				weakSelf?.scrollXBy(position: event.index);
			} else if let event = evt as? PageSelectedByUri {
				weakSelf?.position(of: event.url);
			} else if let _ = evt as? VisibilityChange {
				weakSelf?.toggleView();
			}
		}).addDisposableTo(dispose);
	}
	
	func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
		if message.name == SystemJS.contentReady {
			if let data = message.body as? [String: CGFloat] {
				let width = data[SystemJS.kWidth] ?? 0;
				let height = data[SystemJS.kHeight] ?? 0;
				view.viewFrame(width: width, height: height);
			}
		} else if message.name == SystemJS.contentUpdate {
			if let data = message.body as? [String: Any] {
				let left = (data[SystemJS.kLeft] as? CGFloat) ?? 0;
				let url = (data[SystemJS.kUri] as? String) ?? "";
				if let contents = contents {
					for (index, path) in contents.enumerated() {
						if url.hasSuffix(path) {
							positions[index] = left - width2;
						}
					}
				}
			}
		}
	}
	
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		view.loadJS(js: SystemJS.js);
	}
	
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
		let urlRequest = navigationAction.request;
		if let url = urlRequest.url {
			if let scheme = url.scheme {
				if scheme == SCHEME_HTTP || scheme == SCHEME_HTTPS {
					view.openUrl(url: url);
					decisionHandler(.cancel);
				} else if scheme == SCHEME_FILE {
					if file == url {
						decisionHandler(.allow);
					} else {
						BusManager.post(event: PageSelectedByUri(by: url));
						decisionHandler(.cancel);
					}
				} else {
					decisionHandler(.cancel);
				}
			} else {
				decisionHandler(.cancel);
			}
		} else {
			decisionHandler(.cancel);
		}
	}
	
	func toggleView() {
		if displayState {
			view.showNavigation();
		} else {
			view.hideNavigation();
		}
		displayState = !displayState;
	}
	
	func position(of url: URL) {
		let path = url.lastPathComponent;
		if let contents = contents {
			for (index, content) in contents.enumerated() {
				if content == path {
					scrollXBy(position: index);
				}
			}
		}
	}
	
	func scrollXBy(position: Int) {
		if let x = positions[position] {
			if x >= 0 {
				view.scrollBy(x: x);
			}
		}
	}
	
	func isLogEnabled() -> Bool {
		return true;
	}
	
	func getClassTag() -> String {
		return String(describing: NavigationViewControllerPresenterImp.self);
	}
}
