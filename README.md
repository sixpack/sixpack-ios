# Sixpack-iOS

iOS client library written in Objective-C for SeatGeak's [Sixpack](http://sixpack.seatgeek.com/) ab testing framework.

[![Version](http://cocoapod-badges.herokuapp.com/v/Sixpack-iOS.podspec/badge.png)](http://cocoadocs.org/docsets/Sixpack-iOS.podspec)
[![Platform](http://cocoapod-badges.herokuapp.com/p/Sixpack-iOS.podspec/badge.png)](http://cocoadocs.org/docsets/Sixpack-iOS.podspec)

## Installation

### CocoaPods
The recommended way to use Sixpack-iOS is through [CocoaPods](http://cocoapods.org)

Sixpack-iOS.podspec is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod "Sixpack-iOS.podspec"

### Manual Installation
If you wish to include Sixpack-iOS manually in your project, you must add the SixPackClient Xcode project to your project's workspace.

You will also have to add the appropriate [AFNetworking 2.0](https://github.com/AFNetworking/AFNetworking) source files to the Sixpack-iOS project in order for linking to complete successfully.

## Usage

**1. Connect to the Sixpack host**

Call `connectToHost` before any other Sixpack calls.
Usually inside:    `application:didFinishLaunchingWithOptions:`

The Url should be the location of your sixpack mountpoint:
```objective-c
[Sixpack connectToHost:@"http://my.sixpack.host:8129/sixpack/mount/point"];
```

**2. Set up the experiments**

Call setupExperiment once for each experiment after calling `connectToHost` and before participating:
```objective-c
[Sixpack setupExperiment:@"myExperiment"
           alternatives:@[@"optionA", @"optionB"];
```

**3. Participate in an experiment**

 Call `participate` to participate in an experiment.  The chosen alternative is returned in the `onChoose` block:
```objective-c
[Sixpack participateIn:@"myExperiment"
             onChoose:^(NSString *chosenAlternative) {
        if ([chosenAlternative isEqualToString:@"optionA"]) {
            ... Do option A work
            
        } else if ([chosenAlternative isEqualToString:@"optionB"]) {
            ... Do option B work
        }
    }];

```

**4. Convert**

Call `convert` with the experiment name once the goal is achieved:
```objective-c
[Sixpack convert:@"myExperiment"];
```

### Helper methods


 After participating in an experiment, you can retrieve the chosen alternative for that experiment at any time:
```objective-c
+ (NSString *)chosenAlternativeFor:(NSString *)experiment;
```

 After participating in an experiment, you can check for whether a particular alternative was chosen:
```objective-c
+ (BOOL)chosenAlternativeFor:(NSString *)experiment is:(NSString *)alternative;
```
 For Example:  
```objective-c
 if ([Sixpack chosenAlternativeFor:@"myExperiment" is:@"optionA"]) {
    [self.view addSubview:self.viewA];
 } else {
    [self.view addSubview:self.viewB];
 }
```

### Debugging

 Use this setup method to force an experiment result:
```objective-c
+ (void)setupExperiment:(NSString *)experiment
           alternatives:(NSArray *)alternatives
            forceChoice:(NSString *)forcedChoice;
```

You can turn on and off debug logging.  Logging defaults to On for DEBUG builds and Off for RELEASE builds.
You should ensure this is off before submitting to the app store 
```objective-c
+ (void)enableDebugLogging:(BOOL)debugLogging;
```

## License

Sixpack-iOS is available under the FreeBSD license. See the LICENSE file for more info.

