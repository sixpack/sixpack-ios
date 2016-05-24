//
//  SGSixpackExperiment.m
//  SixpackClient
//
//  Created by James Van-As on 10/10/13.
//  Copyright (c) 2013 SeatGeek Inc. All rights reserved.
//

#import "SGSixpackExperiment.h"
#import "Sixpack.h"
#import "SGHTTPRequest.h"

@interface SGSixpackExperiment ()
@property (nonatomic, assign) BOOL prefetchComplete;
@property (nonatomic, assign) BOOL prefetchInProgress;

@property (nonatomic, assign) BOOL participationComplete;
@property (nonatomic, assign) BOOL participationInProgress;

@property (nonatomic, assign) BOOL conversionComplete;
@property (nonatomic, assign) BOOL conversionInProgress;

@property (nonatomic, assign) BOOL disallowParticipationAndConversion;

@property (assign) BOOL setupCompleteBlockCalled;

@property (nonatomic, strong) SGHTTPRequest *prefetchRequest;
@property (nonatomic, strong) SGHTTPRequest *participationRequest;
@property (nonatomic, strong) SGHTTPRequest *conversionRequest;
@end

@implementation SGSixpackExperiment

- (void)prefetchAlternative {
    if (!self.clientID) {
        SGSixpackDebugLog(@"SIXPACK ERROR (prefetchAlternative): Client ID missing.");
        return;
    }
    if (!self.name) {
        SGSixpackDebugLog(@"SIXPACK ERROR (prefetchAlternative): Experiment name missing.");
        return;
    }
    if (!self.alternatives) {
        SGSixpackDebugLog(@"SIXPACK ERROR (prefetchAlternative): Experiment alternatives missing.");
        return;
    }
    if (!self.url) {
        SGSixpackDebugLog(@"SIXPACK ERROR (prefetchAlternative): Experiment url missing.");
        return;
    }
    if (self.prefetchComplete || self.prefetchInProgress) {
        return;
    }

    self.prefetchInProgress = YES;
    [self.prefetchRequest cancel];

    NSString *url = [self.url stringByAppendingString:@"participate"];
    url = [self addParameter:@"client_id" value:self.clientID toURL:url];
    url = [self addParameter:@"experiment" value:self.name toURL:url];

    for (NSString *alternative in self.alternatives) {
        url = [self addParameter:@"alternatives" value:alternative toURL:url];
    }
    if (self.forcedAlternative) {
        url = [self addParameter:@"force" value:self.forcedAlternative toURL:url];
    }
    url = [self addParameter:@"prefetch" value:@"true" toURL:url];

    self.prefetchRequest = [SGHTTPRequest requestWithURL:[NSURL URLWithString:url]];

    __weak SGSixpackExperiment *me = self;
    self.prefetchRequest.onSuccess = ^(SGHTTPRequest *req) {
        if (!me) {
            return;
        }
        me.prefetchInProgress = NO;
        NSDictionary *responseDict = req.responseJSON;
        SGSixpackDebugLog(@"Sixpack Prefetch Response: %@", responseDict);
        if (responseDict[@"alternative"]) {
            me.chosenAlternative = responseDict[@"alternative"][@"name"];
            me.prefetchComplete = YES;      // allow participations from this point on

            if (!me.setupCompleteBlockCalled && me.setupCompleteBlock) {
                me.setupCompleteBlockCalled = YES;
                me.setupCompleteBlock();
            }
            [NSNotificationCenter.defaultCenter postNotificationName:SGSixpackExperimentSetupComplete
                                                              object:me
                                                            userInfo:@{@"experiment_name" : me.name}];
        }
    };

    self.prefetchRequest.onFailure = ^(SGHTTPRequest *req) {
        if (!me) {
            return;
        }
        SGSixpackDebugLog(@"Sixpack Prefetch Error: %@", req.error);
        me.prefetchInProgress = NO;
        me.disallowParticipationAndConversion = YES;
        me.chosenAlternative = me.forcedAlternative ?: me.alternatives.firstObject;

        //call the completion block.  We don't want to hold up any possible GUI
        if (!me.setupCompleteBlockCalled && me.setupCompleteBlock) {
            me.setupCompleteBlockCalled = YES;
            me.setupCompleteBlock();
        }
        [NSNotificationCenter.defaultCenter postNotificationName:SGSixpackExperimentSetupComplete
                                                          object:me
                                                        userInfo:@{@"experiment_name" : me.name}];
    };

    self.prefetchRequest.onNetworkReachable = ^{
        [me prefetchAlternative];
    };

    [self.prefetchRequest start];

    if (self.setupCompleteBlock && self.setupCompleteBlockTimeout > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.setupCompleteBlockTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.setupCompleteBlockCalled) {
                return;
            }
            self.setupCompleteBlockCalled = YES;
            self.setupCompleteBlock();
            [NSNotificationCenter.defaultCenter postNotificationName:SGSixpackExperimentSetupComplete
                                                              object:self
                                                            userInfo:@{@"experiment_name" : self.name}];
        });
    }
}

/// Participate in this experiment
- (void)participateThen:(void(^)(NSString *chosenAlternative))onChoose {
    if (!onChoose) {
        return;
    }
    if (!self.clientID) {
        SGSixpackDebugLog(@"SIXPACK ERROR (participateThen): Client ID missing.");
        return;
    }
    if (!self.name) {
        SGSixpackDebugLog(@"SIXPACK ERROR (participateThen): Experiment name missing.");
        return;
    }
    if (!self.alternatives) {
        SGSixpackDebugLog(@"SIXPACK ERROR (participateThen): Experiment alternatives missing.");
        return;
    }
    if (!self.url) {
        SGSixpackDebugLog(@"SIXPACK ERROR (participateThen): Experiment url missing.");
        return;
    }

    if (!self.prefetchComplete) {
        self.disallowParticipationAndConversion = YES;
    }
    //return the prefetched alternative immediately to avoid GUI lag.
    if (!self.chosenAlternative) {
        self.disallowParticipationAndConversion = YES;  // we've defaulted to the first alternative.  Don't participate.
        self.chosenAlternative = self.forcedAlternative ?: self.alternatives.firstObject;
    }

    if (self.prefetchComplete && !self.disallowParticipationAndConversion &&
        !self.participationInProgress && !self.participationComplete) {
        self.participationInProgress = YES;
        [self.participationRequest cancel];

        NSString *url = [self.url stringByAppendingString:@"participate"];
        url = [self addParameter:@"client_id" value:self.clientID toURL:url];
        url = [self addParameter:@"experiment" value:self.name toURL:url];

        for (NSString *alternative in self.alternatives) {
            url = [self addParameter:@"alternatives" value:alternative toURL:url];
        }
        if (self.forcedAlternative) {
            url = [self addParameter:@"force" value:self.forcedAlternative toURL:url];
        }

        self.participationRequest = [SGHTTPRequest requestWithURL:[NSURL URLWithString:url]];

        __weak SGSixpackExperiment *me = self;
        self.participationRequest.onSuccess = ^(SGHTTPRequest *req) {
            NSDictionary *responseDict = req.responseJSON;
            SGSixpackDebugLog(@"Sixpack Participate Response: %@", responseDict);
            if (responseDict[@"alternative"]) {
                me.chosenAlternative = responseDict[@"alternative"][@"name"];
            }
            me.participationInProgress = NO;
            me.participationComplete = YES;
        };

        self.participationRequest.onFailure = ^(SGHTTPRequest *req) {
            SGSixpackDebugLog(@"Sixpack Participate Error: %@", req.error);
            me.participationInProgress = NO;
        };

        self.participationRequest.onNetworkReachable = ^{
            [me participateThen:onChoose];
        };
        [self.participationRequest start];
    }

    if (onChoose) {
        onChoose(self.chosenAlternative);
    }
}

/// Convert this experiment
- (void)convert {
    if (!self.chosenAlternative) {
        SGSixpackDebugLog(@"Sixpack Error: Attempting to convert before choosing an alternative");
        return;
    }
    if (!self.clientID) {
        SGSixpackDebugLog(@"SIXPACK ERROR (convert): Client ID missing.");
        return;
    }
    if (!self.name) {
        SGSixpackDebugLog(@"SIXPACK ERROR (convert): Experiment name missing.");
        return;
    }
    if (!self.url) {
        SGSixpackDebugLog(@"SIXPACK ERROR (convert): Experiment url missing.");
        return;
    }
    if (!self.prefetchComplete || !self.participationRequest) {
        return; // don't allow conversion if we haven't completed a prefetch, or if we haven't at least initiated a participation request
    }
    if (self.disallowParticipationAndConversion) {
        return;
    }
    if (self.conversionInProgress || self.conversionComplete) {
        return;
    }
    self.conversionInProgress = YES;
    [self.conversionRequest cancel];

    NSString *url = [self.url stringByAppendingString:@"convert"];
    url = [self addParameter:@"client_id" value:self.clientID toURL:url];
    url = [self addParameter:@"experiment" value:self.name toURL:url];

    self.conversionRequest = [SGHTTPRequest requestWithURL:[NSURL URLWithString:url]];

    __weak SGSixpackExperiment *me = self;
    self.conversionRequest.onSuccess = ^(SGHTTPRequest *req) {
        SGSixpackDebugLog(@"Sixpack Conversion Response: %@", req.responseJSON);
        me.conversionComplete = YES;
        me.conversionInProgress = NO;
    };
    self.conversionRequest.onFailure = ^(SGHTTPRequest *req) {
        SGSixpackDebugLog(@"Sixpack Conversion Error: %@", req.error);
        me.conversionInProgress = NO;
    };
    self.conversionRequest.onNetworkReachable = ^{
        [me convert];
    };

    [self.conversionRequest start];
}

#pragma mark URL helpers

- (NSString *)addParameter:(NSString *)parameter value:(id)value toURL:(NSString *)url {
    if ([url rangeOfString:@"?"].location == NSNotFound) {
        return [url stringByAppendingString:[NSString stringWithFormat:@"?%@=%@", parameter, value]];
    } else {
        return [url stringByAppendingString:[NSString stringWithFormat:@"&%@=%@", parameter, value]];
    }
}

@end
