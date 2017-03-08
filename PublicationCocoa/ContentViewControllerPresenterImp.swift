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

class ContentViewControllerPresenterImp: AbstractPresenter<ContentViewController>,
	ContentViewControllerPresenter, LogType,
	WKUIDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate {
	
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
	
	var gesture: UITapGestureRecognizer {
		get {
			let gesture = UITapGestureRecognizer(target: self, action: #selector((doubleTap(gesture:))));
			gesture.numberOfTapsRequired = 2;
			gesture.delegate = self;
			return gesture;
		}
	}
	var contentUrl: URL?;
	
	override func viewDidLoad() {
		super.viewDidLoad();
		view?.showProgress();
		if let contentUrl = contentUrl {
			view?.load(url: contentUrl);
		}
	}
	
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
		let urlRequest = navigationAction.request;
		if let url = urlRequest.url {
			if let scheme = url.scheme {
				if scheme == SCHEME_HTTP || scheme == SCHEME_HTTPS {
					view?.openUrl(url: url);
					decisionHandler(.cancel);
				} else if scheme == SCHEME_FILE {
					if contentUrl == url {
						decisionHandler(.allow);
					} else {
						BusManager.post(event: PageSelectedByUri(by: url));
						decisionHandler(.cancel);
					}
				} else {
					decisionHandler(.cancel);
				}
			}	else {
				decisionHandler(.cancel);
			}
		} else {
			decisionHandler(.cancel);
		}
	}
	
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		view?.hideProgress();
	}
	
	func doubleTap(gesture: UITapGestureRecognizer) {
		BusManager.post(event: VisibilityChange());
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true;
	}
	
	func isLogEnabled() -> Bool {
		return true;
	}
	
	func getClassTag() -> String {
		return String(describing: ContentViewControllerPresenterImp.self);
	}
}
