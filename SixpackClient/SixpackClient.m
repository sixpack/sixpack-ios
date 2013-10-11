//
//  SixpackClient.m
//  SixpackClient
//
//  Created by James Van-As on 9/10/13.
//  Copyright (c) 2013 SeatGeek Inc. All rights reserved.
//

#import "SixpackClient.h"
#import "SGSixpackClient.h"


@implementation SixpackClient

#pragma mark Public Methods

+ (void)connectToHost:(NSString *)url {
    [self.sharedClient connectToHost:url];
}

/*
 Call setupExperiment once for each experiment after calling connectToHost and before participating
 */
+ (void)setupExperiment:(NSString *)experiment
           alternatives:(NSArray *)alternatives {
    [self.sharedClient setupExperiment:experiment
                          alternatives:alternatives
                           forceChoice:nil];
}

+ (void)setupExperiment:(NSString *)experiment
           alternatives:(NSArray *)alternatives
            forceChoice:(NSString *)forcedChoice {
    [self.sharedClient setupExperiment:experiment
                          alternatives:alternatives
                           forceChoice:forcedChoice];
}

/*==============================================
 Participating in Experiments
 ==============================================*/

/*
 Call participate to participate in an experiment.  The chosen alternative is returned in the onChoose block.
 */
+ (void)participateIn:(NSString *)experiment
             onChoose:(void(^)(NSString *chosenAlternative))block {
    [self.sharedClient participateIn:experiment
                            onChoose:block];
}

/*
 Call convert with the experiment name once the goal is achieved
 */
+ (void)convert:(NSString *)experiment {
    [self.sharedClient convert:experiment];
}

#pragma mark Private Methods

+ (SGSixpackClient *)sharedClient {
    static SGSixpackClient *sharedSixpackClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSixpackClient = SGSixpackClient.new;
    });
    return sharedSixpackClient;
}

@end
