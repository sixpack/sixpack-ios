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
                           forceChoice:nil];
}

+ (void)setupExperiment:(NSString *)experiment
           alternatives:(NSArray *)alternatives
            forceChoice:(NSString *)forcedChoice {
    [self.sharedClient setupExperiment:experiment
                          alternatives:alternatives
                           forceChoice:forcedChoice];
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
