# PublicationCocoa
Previous build had Demo and Library combined in one pack now it is striped from Demo.

```swift
window = UIWindow(frame: Screen.bounds);
let storage = FileStorage();
// directory where you extracty your *.hpub file into
let directory = (storage.directory?.appendingPathComponent("a-study-in-scarlet"))!;
let injector = dependencyInjector as! Container; // container that you AppDelegate extends ApplicationType delegate too.
let viewController = ReadViewController(book: directory, dependency: injector); // directroy URL and injector Container

window!.rootViewController = SnackbarController(rootViewController: viewController);
window!.makeKeyAndVisible();
``` 

New Demo application at [BakerPublicationIOS](https://github.com/droideveloper/BakerPublicationIOS)