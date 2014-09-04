//
//  SixpackClient.m
//  SixpackClient
//
//  Created by James Van-As on 9/10/13.
//  Copyright (c) 2013 SeatGeek Inc. All rights reserved.
//

#import "Sixpack.h"
#import "SGSixpackClient.h"

BOOL __SGSixpackDebugLog_;

@implementation Sixpack

#pragma mark setup

+ (void)connectToHost:(NSString *)url {
    [self.sharedClient connectToHost:url];
}

+ (void)setupExperiment:(NSString *)experiment
           alternatives:(NSArray *)alternatives {
    [self.sharedClient setupExperiment:experiment
                          alternatives:alternatives
                           forceChoice:nil
                       onSetupComplete:nil
                onSetupCompleteTimeout:0];
}

+ (void)setupExperiment:(NSString *)experiment
           alternatives:(NSArray *)alternatives
            forceChoice:(NSString *)forcedChoice {
    [self.sharedClient setupExperiment:experiment
                          alternatives:alternatives
                           forceChoice:forcedChoice
                       onSetupComplete:nil
                onSetupCompleteTimeout:0];
}

+ (void)setupExperiment:(NSString *)experiment
           alternatives:(NSArray *)alternatives
        onSetupComplete:(void(^)())doBlock
                timeOut:(NSTimeInterval)timeOut {
    [self.sharedClient setupExperiment:experiment
                          alternatives:alternatives
                           forceChoice:nil
                       onSetupComplete:doBlock
                onSetupCompleteTimeout:timeOut];
}

+ (void)setupExperiment:(NSString *)experiment
           alternatives:(NSArray *)alternatives
            forceChoice:(NSString *)forcedChoice
        onSetupComplete:(void(^)())doBlock
                timeOut:(NSTimeInterval)timeOut {
    [self.sharedClient setupExperiment:experiment
                          alternatives:alternatives
                           forceChoice:forcedChoice
                       onSetupComplete:doBlock
                onSetupCompleteTimeout:timeOut];
}

#pragma mark participation

+ (void)participateIn:(NSString *)experiment
             onChoose:(void(^)(NSString *chosenAlternative))block {
    [self.sharedClient participateIn:experiment
                            onChoose:block];
}

+ (void)convert:(NSString *)experiment {
    [self.sharedClient convert:experiment];
}

#pragma mark helper methods

+ (NSString *)chosenAlternativeFor:(NSString *)experiment {
    return [self.sharedClient chosenAlternativeFor:experiment];
}


+ (BOOL)chosenAlternativeFor:(NSString *)experiment is:(NSString *)alternative {
    return [self.sharedClient chosenAlternativeFor:experiment is:alternative];
}

+ (NSString *)clientID {
    return self.sharedClient.clientID;
}

#pragma mark private methods

+ (SGSixpackClient *)sharedClient {
    static SGSixpackClient *sharedSixpackClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSixpackClient = SGSixpackClient.new;
    });
    return sharedSixpackClient;
}

+ (void)enableDebugLogging:(BOOL)debugLogging {
    __SGSixpackDebugLog_ = debugLogging;
}

+ (void)initialize {
#ifdef DEBUG
    __SGSixpackDebugLog_ = YES;
#else
    __SGSixpackDebugLog_ = NO;
#endif
}

@end
