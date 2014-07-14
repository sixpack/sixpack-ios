//
//  SGSixpackClient.m
//  SixpackClient
//
//  Created by James Van-As on 9/10/13.
//  Copyright (c) 2013 SeatGeek Inc. All rights reserved.
//

#import "SGSixpackClient.h"
#import "AFNetworking/AFNetworking.h"
#import "SGSixpackExperiment.h"
#import "SGNetworkQueue.h"

@implementation SGSixpackClient
{
    NSString *_url;
    NSString *_clientID;
    NSMutableDictionary *_experiments;
    SGNetworkQueue *_networkQueue;
}

- (void)connectToHost:(NSString *)url {
    _url = url;
    _experiments = NSMutableDictionary.new;
    _networkQueue = SGNetworkQueue.new;

    _operationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:_url]];
    _operationManager.responseSerializer = AFJSONResponseSerializer.serializer;
    
    __weak SGSixpackClient *me = self;
    [_operationManager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [me networkReachabilityChanged:status];
    }];
}

- (void)setupExperiment:(NSString *)experiment
           alternatives:(NSArray *)alternatives
            forceChoice:(NSString *)forcedChoice
        onSetupComplete:(void(^)())doBlock
 onSetupCompleteTimeout:(NSTimeInterval)timeOut {
    
    if (!_operationManager || !_url) {
        SGSixpackDebugLog(@"SIXPACK ERROR (setupExperiment): You must first connect to the sixpack host before setting up an experiment.");
        return;
    }
    if (!experiment) {
        SGSixpackDebugLog(@"SIXPACK ERROR (setupExperiment): You must specify an experiment name.");
        return;
    }
    if (!alternatives || alternatives.count < 2) {
        SGSixpackDebugLog(@"SIXPACK ERROR (setupExperiment): You must provide at least 2 alternatives.");
        return;
    }
    if (_experiments[ experiment ]) {
        SGSixpackDebugLog(@"SIXPACK ERROR (setupExperiment): Experiment name already exists.");
        return;
    }
    
    SGSixpackExperiment *experimentObj = SGSixpackExperiment.new;
    experimentObj.name = experiment;
    experimentObj.alternatives = alternatives;
    experimentObj.forcedAlternative = forcedChoice;
    experimentObj.clientID = self.clientID;
    experimentObj.url = _url;
    experimentObj.operationManager = _operationManager;
    experimentObj.setupCompleteBlock = doBlock;
    experimentObj.setupCompleteBlockTimeout = timeOut;
    _experiments[ experiment ] = experimentObj;

    [_networkQueue addPrefetchOperationFor:experimentObj];
}

- (void)participateIn:(NSString *)experiment onChoose:(void(^)(NSString *chosenAlternative))block {
    if (!experiment) {
        SGSixpackDebugLog(@"SIXPACK ERROR (participateIn): You must specify an experiment name.");
        return;
    }
    if (!block) {
        SGSixpackDebugLog(@"SIXPACK ERROR (participateIn): You must specify a completion block.");
        return;
    }
    
    SGSixpackExperiment *experimentObj = _experiments[experiment];
    if (!experimentObj) {
        SGSixpackDebugLog(@"SIXPACK ERROR (participateIn): You must set up an experiment before participating.");
        return;
    }
    [_networkQueue addParticipateOperationFor:experimentObj];
    
    //return the prefetched alternative immediately to avoid GUI lag.
    
    if (!experimentObj.chosenAlternative) {
        experimentObj.chosenAlternative = experimentObj.alternatives.firstObject;
    }
    block(experimentObj.chosenAlternative);
}

- (void)convert:(NSString *)experiment {
    if (!experiment) {
        SGSixpackDebugLog(@"SIXPACK ERROR (convert): You must specify an experiment name.");
        return;
    }

    SGSixpackExperiment *experimentObj = _experiments[experiment];
    if (!experimentObj) {
        SGSixpackDebugLog(@"SIXPACK ERROR (convert): You must set up an experiment before converting.");
        return;
    }
    [_networkQueue addConversionOperationFor:experimentObj];
}

#pragma mark Network Reachability

- (void)networkReachabilityChanged:(AFNetworkReachabilityStatus)status {
    switch (status) {
        case AFNetworkReachabilityStatusReachableViaWiFi:
        case AFNetworkReachabilityStatusReachableViaWWAN:
            [_networkQueue enableQueues:YES];
            [_networkQueue startQueues];
            break;
        default:
            //unreachable
            [_networkQueue enableQueues:NO];
            [_networkQueue stopQueues];
            break;
    }
}

#pragma mark client identification
- (NSString *)clientID {
    if (_clientID) {
        return _clientID;
    }
    _clientID = [[NSUserDefaults standardUserDefaults] objectForKey:@"sixpackClientID"];
    if (!_clientID) {
        _clientID = [UIDevice currentDevice].identifierForVendor.UUIDString;
        if (_clientID) {
            [[NSUserDefaults standardUserDefaults] setValue:_clientID forKey:@"sixpackClientID"];
        }
    }
    return _clientID;
}

#pragma mark helpers

- (NSString *)chosenAlternativeFor:(NSString *)experiment {
    if (!experiment) {
        return nil;
    }
    SGSixpackExperiment *experimentObj = _experiments[experiment];
    return experimentObj.chosenAlternative;
}

- (BOOL)chosenAlternativeFor:(NSString *)experiment is:(NSString *)alternative {
    if (!experiment || !alternative) {
        SGSixpackDebugLog(@"SIXPACK ERROR (chosenAlternativeFor): Bad experiment or alternative name.  Forcing a choice.");
        return YES; //force a choice
    }
    SGSixpackExperiment *experimentObj = _experiments[experiment];
    if (!experimentObj) {
        SGSixpackDebugLog(@"SIXPACK ERROR (chosenAlternativeFor): Bad experiment or alternative name.  Forcing a choice.");
        return YES;
    }
    
    if (!experimentObj.chosenAlternative) {
        SGSixpackDebugLog(@"SIXPACK ERROR (chosenAlternativeFor): No alternative has been chosen.  Forcing a choice.");
        return YES;
    }

    return [experimentObj.chosenAlternative isEqualToString:alternative];
}

@end
