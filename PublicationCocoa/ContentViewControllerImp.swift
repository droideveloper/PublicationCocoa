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
 
import UIKit
import WebKit

import MVPCocoa
import Material

class ContentViewControllerImp: AbstractPageViewHolder<URL, ContentViewControllerPresenter>,
	ContentViewController, LogType {
	
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
	
	override var item: URL? {
		didSet {
			if let presenter = presenter as? ContentViewControllerPresenterImp {
				presenter.contentUrl = item;
			}
		}
	}
	
	override func prepare() {
		super.prepare();
		let wkWebView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration());
		if let presenter = presenter {
			wkWebView.uiDelegate = presenter.udelegate;
			wkWebView.navigationDelegate = presenter.ndelegate;
			wkWebView.scrollView.addGestureRecognizer(presenter.gesture);
		}
		view.layout(wkWebView)
			.edges();
		let progress = UIActivityIndicatorView(activityIndicatorStyle: .gray);
		if let application = application {
			progress.color = application.colorAccent;
		}
		view.layout(progress)
			.center();
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
	
	func openUrl(url: URL) {
		// TODO make a pop-up to use it
		if #available(iOS 10.0, *) {
			UIApplication.shared.open(url, options: [:], completionHandler: nil);
		} else {
			UIApplication.shared.openURL(url);
		};
	}
	
	func isLogEnabled() -> Bool {
		return true;
	}
	
	func getClassTag() -> String {
		return String(describing: ContentViewControllerImp.self);
	}
}
