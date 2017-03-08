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
import Swinject

import RxSwift

class ViewPagerControllerPresenterImp: AbstractPresenter<ViewPagerController>,
	ViewPagerControllerPresenter, LogType, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
	
	let index   = "index.htm";
	let index2  = "index.html";
	let dispose = DisposeBag();
	
	var directory: URL?;
	var contents: [String]?;
	
	var dataSource: UIPageViewControllerDataSource {
		get {
			return self;
		}
	}
	
	var delegate: UIPageViewControllerDelegate {
		get {
			return self;
		}
	}
	
	private var viewController: UIPageViewController? {
		get {
			return view as? UIPageViewController;
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad();
		BusManager.register(next: { [weak weakSelf = self] evt in
			if let event = evt as? PageSelectedByUri {
				weakSelf?.changeIndex(to: event.url);
			}
		}).addDisposableTo(dispose);
		// load book
		if let directory = directory {
			if let component = view?.application?.component as? Container {
				if let fileStorage = component.resolve(FileStorageType.self) {
					if let configuration = fileStorage.read(in: directory) {
						BusManager.post(event: TitleChangeEvent(configuration.title));
						contents = configuration.contents;
						view?.setCurrentPage(of: viewControllerAtIndex(index: 0), by: .forward);
					}
				}
			}
			// if there is navigation view we add those
			let manager = FileManager.default;
			let fileIndex = directory.appendingPathComponent(index);
			let fileIndex2 = directory.appendingPathComponent(index2);
			if manager.fileExists(atPath: fileIndex.path) {
				view?.addNavigationViewController(for: fileIndex, with: contents);
			} else if manager.fileExists(atPath: fileIndex2.path) {
				view?.addNavigationViewController(for: fileIndex2, with: contents);
			}
		}
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		if finished && completed {
			let index = indexAt(of: pageViewController);
			BusManager.post(event: PageSelectedByIndex(by: index));
		}
	}
	
	func changeIndex(to: URL) {
		if let viewController = viewController {
			let current = indexAt(of: viewController);
			let file = to.lastPathComponent;
			if let contents = contents {
				for (index, content) in contents.enumerated() {
					if file == content {
						if index < current {
							view?.setCurrentPage(of: viewControllerAtIndex(index: index), by: .reverse);
							BusManager.post(event: PageSelectedByIndex(by: index));
						} else if index > current {
							view?.setCurrentPage(of: viewControllerAtIndex(index: index), by: .forward);
							BusManager.post(event: PageSelectedByIndex(by: index));
						}
					}
				}
			}
		}
	}
	
	func indexAt(of viewController: UIPageViewController) -> Int {
		if let viewController = viewController.viewControllers?.last as? ContentViewControllerImp {
			return viewController.position ?? -1;
		}
		return -1;
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		if let viewController = viewController as? ContentViewControllerImp {
			if let index = viewController.position {
				return viewControllerAtIndex(index: index + 1);
			}
		}
		return nil;
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		if let viewController = viewController as? ContentViewControllerImp {
			if let index = viewController.position {
				return viewControllerAtIndex(index: index - 1);
			}
		}
		return nil;
	}
	
	func viewControllerAtIndex(index: Int) -> ContentViewControllerImp? {
		if let contents = contents, let component = view?.application?.component as? Container, let directory = directory {
			if index >= 0 && index < contents.size() {
				if let viewController = component.resolve(ContentViewController.self) as? ContentViewControllerImp {
					if let path = contents.get(index: index) {
						viewController.item = directory.appendingPathComponent(path);
					}
					viewController.position = index;
					return viewController;
				}
			}
		}
		return nil;
	}
	
	func presentationCount(for pageViewController: UIPageViewController) -> Int {
		if let contents = contents {
			return contents.size();
		}
		return 0;
	}

	
	func isLogEnabled() -> Bool {
		return true;
	}
	
	func getClassTag() -> String {
		return String(describing: ViewPagerControllerPresenterImp.self);
	}
}
