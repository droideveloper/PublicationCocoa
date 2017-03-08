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
import UIKit

import MVPCocoa
import Material

class NavigationViewControllerImp: AbstractViewController<NavigationViewControllerPresenter>,
	NavigationViewController, LogType {
	
	var wkWebView: WKWebView? {
		get {
			for view in view.subviews {
				if let view = view as? WKWebView {
					return view;
				}
			}
			return nil;
		}
	}
	
	override func prepare() {
		super.prepare();
		self.view = View(frame: CGRect(x: 0, y: 0, width: Screen.width, height: 1));
		let configuration = WKWebViewConfiguration();
		let control = WKUserContentController();
		if let presenter = presenter {
			control.add(presenter.jdelegate, name: SystemJS.contentReady);
			control.add(presenter.jdelegate, name: SystemJS.contentUpdate);
		}
		configuration.userContentController = control;
		let wkWebView = WKWebView(frame: .zero, configuration: configuration);
		if let presenter = presenter {
			wkWebView.uiDelegate = presenter.udelegate;
			wkWebView.navigationDelegate = presenter.ndelegate;
		}
		view.layout(wkWebView)
			.edges();
	}
	
	func load(url: URL) {
		if #available(iOS 9.0, *) {
			if let wkWebView = wkWebView {
				wkWebView.loadFileURL(url, allowingReadAccessTo: url);
			}
		} else {
			// TODO ensure for 8.0 extract *.hpub file into /temp/www folder
			if let wkWebView = wkWebView {
				wkWebView.load(URLRequest(url: url));
			}
		}
	}
	
	func loadJS(js: String) {
		if let wkWebView = wkWebView {
			wkWebView.evaluateJavaScript(js);
		}
	}
	
	func openUrl(url: URL) {
		// TODO make a pop-up to use it
		if #available(iOS 10.0, *) {
			UIApplication.shared.open(url, options: [:], completionHandler: nil);
		} else {
			UIApplication.shared.openURL(url);
		};
	}
	
	func viewFrame(width: CGFloat, height: CGFloat) {
		if let heightConstraint = view.heightConstraint {
			UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut,  animations: { [weak weakSelf = self] in
				heightConstraint.constant = height;
				weakSelf?.view.layoutIfNeeded();
			}, completion: { [weak weakSelf = self] _ in
				weakSelf?.scrollBy(x: 0);
			});
		}
	}
	
	func scrollBy(x: CGFloat) {
		if let view = wkWebView?.scrollView {
			UIView.animate(withDuration: 0.3, animations: {
				view.contentOffset.x = x;
			});
		}
	}
	
	func showNavigation() {
		UIView.animate(withDuration: 0.3, animations: { [weak weakSelf = self] in
			weakSelf?.view.transform = CGAffineTransform.identity;
		});
	}
	
	func hideNavigation() {
		let height = view.height;
		UIView.animate(withDuration: 0.3, animations: { [weak weakSelf = self] in
			weakSelf?.view.transform = CGAffineTransform.identity.translatedBy(x: 0, y: height);
		});
	}
	
	func isLogEnabled() -> Bool {
		return true;
	}
	
	func getClassTag() -> String {
		return String(describing: NavigationViewControllerImp.self);
	}
}
