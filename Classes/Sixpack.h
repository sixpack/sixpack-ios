//
//  Sixpack.h
//  Sixpack
//
//  Created by James Van-As on 9/10/13.
//  Copyright (c) 2013 SeatGeek Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sixpack : NSObject

/*==============================================
Setting up Sixpack Client and experiments
==============================================*/

/*
Call connectToHost before any other Sixpack calls.
Usually inside:    application:didFinishLaunchingWithOptions:

Url should be the location of your sixpack mountpoint
eg. http://my.sixpack.host:8129/sixpack/mount/point
*/

+ (void)connectToHost:(NSString *)url;

/* Turn on debug logging.  Defaults to On for DEBUG builds and Off for RELEASE builds.
You should ensure this is off before submitting to the app store 
*/
+ (void)enableDebugLogging:(BOOL)debugLogging;

/*
Call setupExperiment once for each experiment after calling connectToHost and before participating
*/
+ (void)setupExperiment:(NSString *)experiment
           alternatives:(NSArray *)alternatives;

/*
 Use this setup method to force an experiment result
 */
+ (void)setupExperiment:(NSString *)experiment
           alternatives:(NSArray *)alternatives
            forceChoice:(NSString *)forcedChoice;

/*==============================================
 Participating in Experiments
 ==============================================*/

/*
 Call participate to participate in an experiment.  The chosen alternative is returned in the onChoose block.
 */
+ (void)participateIn:(NSString *)experiment
             onChoose:(void(^)(NSString *chosenAlternative))block;
/*
 Call convert with the experiment name once the goal is achieved
 */
+ (void)convert:(NSString *)experiment;


/*==============================================
 Helper Methods
 ==============================================*/

/*
 After participating in an experiment, you can retreive the chosen alternative for that experiment at any time.
 */
+ (NSString *)chosenAlternativeFor:(NSString *)experiment;

/*
 After participating in an experiment, you can check for whether a particular alternative was chosen.
 
 eg.  
 if ([Sixpack chosenAlternativeFor:@"myExperiment" is:@"optionA"]) {
    [self.view addSubview:self.viewA];
 } else {
    [self.view addSubview:self.viewB];
 }
 */
+ (BOOL)chosenAlternativeFor:(NSString *)experiment is:(NSString *)alternative;

@end
