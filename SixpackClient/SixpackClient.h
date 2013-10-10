//
//  SixpackClient.h
//  SixpackClient
//
//  Created by James Van-As on 9/10/13.
//  Copyright (c) 2013 SeatGeek Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SixpackClient : NSObject

/*==============================================
Setting up Sixpack Client and experiments
==============================================*/

/*
Call connectToHost before any other Sixpack calls.
Usually inside:    application:didFinishLaunchingWithOptions:

Url should be the location of your sixpack mountpoint
eg. http://my.sixpack.host:8129/sixpack/mount/point
*/

// Connect with the default timeout of 0.5 seconds.
+ (void)connectToHost:(NSString *)url;

+ (void)connectToHost:(NSString *)url
               timout:(NSTimeInterval)seconds;

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

@end
