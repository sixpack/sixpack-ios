//
//  SGSixpackClient.h
//  SixpackClient
//
//  Created by James Van-As on 9/10/13.
//  Copyright (c) 2013 SeatGeek Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFHTTPSessionManager, SGSixpackExperiment;

@interface SGSixpackClient : NSObject

//setup
- (void)connectToHost:(NSString *)url;
- (void)setupExperiment:(NSString *)experiment
           alternatives:(NSArray *)alternatives
            forceChoice:(NSString *)forcedChoice
        onSetupComplete:(void(^)())doBlock
 onSetupCompleteTimeout:(NSTimeInterval)timeOut;

//participation
- (void)participateIn:(NSString *)experiment
             onChoose:(void(^)(NSString *chosenAlternative))block;
- (void)convert:(NSString *)experiment;

//helpers
- (NSArray <SGSixpackExperiment *> *)activeExperiments;
- (NSString *)chosenAlternativeFor:(NSString *)experiment;
- (BOOL)chosenAlternativeFor:(NSString *)experiment is:(NSString *)alternative;
- (NSString *)clientID;

@end
