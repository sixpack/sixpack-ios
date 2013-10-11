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
            forceChoice:(NSString *)forcedChoice {
    if (!_operationManager || !_url) {
        NSLog(@"SIXPACK ERROR (setupExperiment): You must first connect to the sixpack host before setting up an experiment.");
        return;
    }
    if (!experiment) {
        NSLog(@"SIXPACK ERROR (setupExperiment): You must specify an experiment name.");
        return;
    }
    if (!alternatives || alternatives.count < 2) {
        NSLog(@"SIXPACK ERROR (setupExperiment): You must provide at least 2 alternatives.");
        return;
    }
    if (_experiments[ experiment ]) {
        NSLog(@"SIXPACK ERROR (setupExperiment): Experiment name already exists.");
        return;
    }
    
    SGSixpackExperiment *experimentObj = SGSixpackExperiment.new;
    experimentObj.name = experiment;
    experimentObj.alternatives = alternatives;
    experimentObj.forcedAlternative = forcedChoice;
    experimentObj.clientID = self.clientID;
    experimentObj.url = _url;
    experimentObj.operationManager = _operationManager;
    _experiments[ experiment ] = experimentObj;
    [_networkQueue addPrefetchOperationFor:experimentObj];
}

- (void)participateIn:(NSString *)experiment onChoose:(void(^)(NSString *chosenAlternative))block {
    if (!experiment) {
        NSLog(@"SIXPACK ERROR (participateIn): You must specify an experiment name.");
        return;
    }
    if (!block) {
        NSLog(@"SIXPACK ERROR (participateIn): You must specify a completion block.");
        return;
    }
    
    SGSixpackExperiment *experimentObj = _experiments[experiment];
    if (!experimentObj) {
        NSLog(@"SIXPACK ERROR (participateIn): You must set up an experiment before participating.");
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
        NSLog(@"SIXPACK ERROR (convert): You must specify an experiment name.");
        return;
    }

    SGSixpackExperiment *experimentObj = _experiments[experiment];
    if (!experimentObj) {
        NSLog(@"SIXPACK ERROR (convert): You must set up an experiment before converting.");
        return;
    }
    [_networkQueue addConversionOperationFor:experimentObj];
}

#pragma mark Network Reachability

- (void)networkReachabilityChanged:(AFNetworkReachabilityStatus)status {
    switch (status) {
        case AFNetworkReachabilityStatusReachableViaWiFi:
        case AFNetworkReachabilityStatusReachableViaWWAN:
            [_networkQueue startQueues];
            break;
        default:
            //unreachable
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

@end
