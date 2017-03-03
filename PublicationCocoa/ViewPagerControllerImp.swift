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

import MVPCocoa
import Material

import Swinject

class ViewPagerControllerImp: AbstractViewPagerController<ViewPagerControllerPresenter>,
	ViewPagerController, LogType {
	
	var directory: URL? {
		didSet {
			if let presenter = presenter as? ViewPagerControllerPresenterImp {
				presenter.directory = directory;
			}
		}
	}
	
	convenience init() {
		self.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil);
	}
	
	override func prepare() {
		super.prepare();
		if let presenter = presenter {
			dataSource = presenter.dataSource;
			delegate = presenter.delegate;
		}
	}
	
	func addNavigationViewController(for url: URL?, with contents: [String]?) {
		if let dependencyInjector = application?.dependencyInjector as? Container {
			if let navigationViewController = dependencyInjector.resolve(NavigationViewController.self) as? NavigationViewControllerImp {
				if let navigationViewControllerPresenter = navigationViewController.presenter as? NavigationViewControllerPresenterImp {
					navigationViewControllerPresenter.file = url;
					navigationViewControllerPresenter.contents = contents;
					// add it into child
					addChildViewController(navigationViewController);
					view.layout(navigationViewController.view)
						.bottom();
					navigationViewController.didMove(toParentViewController: self);
				}
			}
		}
	}
	
	func setCurrentPage(of viewController: UIViewController?, by direction: UIPageViewControllerNavigationDirection) {
		if let viewController = viewController {
			setViewControllers([viewController], direction: direction, animated: true, completion: nil);
		}
	}
	
	func isLogEnabled() -> Bool {
		return true;
	}
	
	func getClassTag() -> String {
		return String(describing: ViewPagerControllerImp.self);
	}
}
