HexKeyboard
===========

An iOS keyboard, that supports entering hex-values to the UITextField.

## Requirements

- Minimum Deployment Target: 9.0


## Installation

### Manual

Copy the **header**, **implementation** and the **image** files to your project.


### CocoaPods

To integrate HexKeyboard in your app use [CocoaPods](http://guides.cocoapods.org/using/getting-started.html). Add this to your Podfile:

```bash
  pod 'MRHexKeyboard', :git => 'https://github.com/doofyus/HexKeyboard.git', :branch => "master"
```

## Usage

Set`MRHexKeyboard` to the *UITextField's inputView* in *viewDidLoad* (or where you find it most suitable).

Obj-c:

```
	aTextField.inputView = [[MRHexKeyboard alloc] init];
```

Swift:

```
	aTextField.inputView = MRHexKeyboard()
```
 
## License

HexKeyboard is released under the [MIT License](LICENSE).

  

