# ios-foodie

## Quick Start

1. Download and install the latest version of Xcode here:  https://itunes.apple.com/ca/app/xcode/id497799835?mt=12
2. Install Cocoapods (dependency manager https://cocoapods.org/) by running:
```
$ sudo gem install cocoapods
```
3. Clone this repo, `cd` into the directory with `Podfile`, and run
```
$ pod install
```
4. You can now dive into the project by opening up `foodie.xcworkspace` (not `foodie.xcodeproj`)

## Style Guide

We follow SwiftLint, which can be found here: https://github.com/realm/SwiftLint

It is packaged as a pod in Xcode, which will run for every local build.

You should also install it in your CLI by running:
```
$ brew install swiftlint
```

You should setup the shell script, `pre-commit-swiftlint.sh`, located at the root directory as a pre-commit git hook.
`cd` into the root directory and run:
```
$ ln -s ../../pre-commit-swiftlint.sh .git/hooks/pre-commit
$ chmod +x .git/hooks/pre-commit
```

Finally, SwiftLint can autocorrect some of the formatting errors. Do this by running:
```
$ swiftlint autocorrect --path foodie/
```
## References

Zeplin: https://zpl.io/29Dg7Oe

Drive: https://drive.google.com/drive/folders/1bbgpnBTfIbCQREScvKhMrwMMcgxn38zn
