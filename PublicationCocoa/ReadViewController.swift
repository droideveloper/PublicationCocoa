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
 
import MVPCocoa
import Material

import RxSwift
import Swinject

open class ReadViewController: ToolbarController, LogType {
	
	private let dispose = DisposeBag();
	private var displayState: Bool = false;
	
	private var callback: (() -> Void)?;
	
	private var pageButton: IconButton? {
		get {
			for view in toolbar.rightViews {
				if let view = view as? IconButton {
					return view;
				}
			}
			return nil;
		}
	}
	
	open override func layoutSubviews() {
		super.layoutSubviews();
		switch toolbarDisplay {
		case .full:
			if let statusBarController = statusBarController {
				let h = statusBarController.statusBar.height;
				rootViewController.view.y = h;
				rootViewController.view.height = view.height - h;
			}
		case .partial:
			break;
		}
	}
	
	public convenience init(book url: URL, callback: (() -> Void)? = nil) {
		if let component = Application.shared?.component as? Container {
			if let viewController = component.resolve(ViewPagerController.self) as? ViewPagerControllerImp {
				viewController.directory = url;
				self.init(rootViewController: viewController);
				self.callback = callback;
			} else {
				fatalError("can not resolve viewController since ApplicationType not implemented in UIApplicationDelegate");
			}
		} else {
			fatalError("ApplicationType not implemented in UIApplicationDelegate");
		}
	}
	
	open override func viewWillAppear(_ animated: Bool) {
		super.viewDidAppear(animated);
		// however this produce something interesting bug
		self.toolbarDisplay = .full;
	}
	
	open override func viewDidLoad() {
		super.viewDidLoad();
		BusManager.register(next: { [weak weakSelf = self] evt in
			if let event = evt as? PageSelectedByIndex {
				weakSelf?.setCurrentPageText(at: event.index);
			} else if let event = evt as? TitleChangeEvent {
				weakSelf?.toolbar.title = event.title;
			}	else if let _ = evt as? VisibilityChange {
				weakSelf?.toggleDisplayState();
			}
		}).addDisposableTo(dispose);
		// change data content
		Observable.just(VisibilityChange())
			.delay(3, scheduler: RxSchedulers.mainThread)
			.filter { [weak weakSelf = self] _ in !(weakSelf?.displayState ?? true) }
			.subscribe(onNext: { event in
				BusManager.post(event: event);
			}).addDisposableTo(dispose);
	}
	
	open override func prepare() {
		super.prepare();
		if let theme = application {
			statusBarStyle = .lightContent;
			statusBar.backgroundColor = theme.colorPrimaryDark;
			toolbar.backgroundColor = theme.colorPrimary;
			
			toolbar.titleLabel.textColor = .white;
			toolbar.titleLabel.font = RobotoFont.light(with: 16);
			toolbar.titleLabel.textAlignment = .left;
		}
		
		let backButton = IconButton(image: Material.icon(.ic_arrow_back), tintColor: .white);
		backButton.addTarget(self, action: #selector(backPressed), for: .touchUpInside);
		toolbar.leftViews = [backButton];
		
		let pageButton = IconButton(title: "1", titleColor: .white);
		toolbar.rightViews = [pageButton];
	}
	
	func backPressed() {
		if let navigationController = navigationController  {
			navigationController.popViewController(animated: true);
		}
		if let callback = callback {
			callback();
		}
	}
	
	func toggleDisplayState() {
		if displayState {
			showToolbar();
		} else {
			hideToolbar();
		}
		displayState = !displayState;
	}
	
	func showToolbar() {
		let translateY = self.toolbar.height + self.statusBar.height;
		UIView.animate(withDuration: 0.3, animations: { [unowned self] in
			self.toolbar.y += translateY;
		});
	}
	
	func hideToolbar() {
		let translateY = self.toolbar.height + self.statusBar.height;
		UIView.animate(withDuration: 0.3, animations: { [unowned self] in
			self.toolbar.y -= translateY;
		});
	}
	
	open func setCurrentPageText(at index: Int) {
		if let pageButton = pageButton {
			pageButton.title = "\(index + 1)";
		}
	}
	
	public func isLogEnabled() -> Bool {
		return true;
	}
	
	public func getClassTag() -> String {
		return String(describing: ReadViewController.self);
	}
}
