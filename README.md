# PublicationCocoa
Previous build had Demo and Library combined in one pack now it is striped from Demo.

```swift
window = UIWindow(frame: Screen.bounds);
// directory where you extracty your *.hpub file into
let viewController = ReadViewController(book: directory);
// SnackbarController is not needed since it will just use it to show snackbar messages
window!.rootViewController = SnackbarController(rootViewController: viewController);
window!.makeKeyAndVisible();
``` 

New Demo application at [BakerPublicationIOS](https://github.com/droideveloper/BakerPublicationCocoa)