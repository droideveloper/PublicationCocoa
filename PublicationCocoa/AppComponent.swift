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

import Swinject

open class AppComponent {
	
	open var component: Container;
	
	public init() {
		self.component = Container();
		self.component.register(FileStorageType.self) { _ in
			return FileStorage();
		}.inObjectScope(.container);
		self.component.register(ContentViewController.self) { _ in
			return ContentViewControllerImp(position: 0, item: URL(fileURLWithPath: NSTemporaryDirectory()));
		}.initCompleted { (_, viewController) in
			if let viewController = viewController as? ContentViewControllerImp {
				viewController.presenter = ContentViewControllerPresenterImp(viewController);
			}
		}.inObjectScope(.graph);
		self.component.register(NavigationViewController.self) { _ in
			return NavigationViewControllerImp();
		}.initCompleted { (_, viewController) in
			if let viewController = viewController as? NavigationViewControllerImp {
				viewController.presenter = NavigationViewControllerPresenterImp(viewController);
			}
		}.inObjectScope(.graph);
		self.component.register(ViewPagerController.self) { _ in
			return ViewPagerControllerImp();
		}.initCompleted { (_, viewController) in
			if let viewController = viewController as? ViewPagerControllerImp {
				viewController.presenter = ViewPagerControllerPresenterImp(viewController);
			}
		}.inObjectScope(.graph);
	}
}
