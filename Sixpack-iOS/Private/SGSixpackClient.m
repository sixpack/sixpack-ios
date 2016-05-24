//
//  SGSixpackClient.m
//  SixpackClient
//
//  Created by James Van-As on 9/10/13.
//  Copyright (c) 2013 SeatGeek Inc. All rights reserved.
//

#import "SGSixpackClient.h"
#import "SGSixpackExperiment.h"

@interface SGSixpackClient ()
@property (nonatomic, strong) NSString *hostURL;
@property (nonatomic, strong) NSString *clientID;
@property (nonatomic, strong) NSMutableDictionary *experiments;
@end

@implementation SGSixpackClient

- (void)connectToHost:(NSString *)url {
    self.hostURL = url;
}

- (void)setupExperiment:(NSString *)experiment
           alternatives:(NSArray *)alternatives
            forceChoice:(NSString *)forcedChoice
        onSetupComplete:(void(^)())doBlock
 onSetupCompleteTimeout:(NSTimeInterval)timeOut {
    if (!self.hostURL) {
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
    if (self.experiments[experiment] && !forcedChoice.length) {
        SGSixpackDebugLog(@"SIXPACK ERROR (setupExperiment): Experiment name already exists.");
        return;
    }
    
    SGSixpackExperiment *experimentObj = SGSixpackExperiment.new;
    experimentObj.name = experiment;
    experimentObj.alternatives = alternatives;
    experimentObj.forcedAlternative = forcedChoice;
    experimentObj.clientID = self.clientID;
    experimentObj.url = self.hostURL;
    experimentObj.setupCompleteBlock = doBlock;
    experimentObj.setupCompleteBlockTimeout = timeOut;
    self.experiments[experiment] = experimentObj;
    [experimentObj prefetchAlternative];
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
    
    SGSixpackExperiment *experimentObj = self.experiments[experiment];
    if (!experimentObj) {
        SGSixpackDebugLog(@"SIXPACK ERROR (participateIn): You must set up an experiment before participating.");
        return;
    }

    [experimentObj participateThen:block];
}

- (void)convert:(NSString *)experiment {
    if (!experiment) {
        SGSixpackDebugLog(@"SIXPACK ERROR (convert): You must specify an experiment name.");
        return;
    }

    SGSixpackExperiment *experimentObj = self.experiments[experiment];
    if (!experimentObj) {
        SGSixpackDebugLog(@"SIXPACK ERROR (convert): You must set up an experiment before converting.");
        return;
    }
    [experimentObj convert];
}

#pragma mark Helpers

- (NSArray <SGSixpackExperiment *> *)activeExperiments {
    NSDictionary *experiments = self.experiments.copy;
    NSMutableArray *list = NSMutableArray.new;
    for (NSString *experimentName in experiments) {
        [list addObject:experiments[experimentName]];
    }
    return list.copy;
}

- (NSString *)chosenAlternativeFor:(NSString *)experiment {
    if (!experiment) {
        return nil;
    }
    SGSixpackExperiment *experimentObj = self.experiments[experiment];
    return experimentObj.chosenAlternative;
}

- (BOOL)chosenAlternativeFor:(NSString *)experiment is:(NSString *)alternative {
    if (!experiment || !alternative) {
        SGSixpackDebugLog(@"SIXPACK ERROR (chosenAlternativeFor): Bad experiment or alternative name.  Forcing a choice.");
        return YES; //force a choice
    }
    SGSixpackExperiment *experimentObj = self.experiments[experiment];
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

#pragma mark Getters

- (NSMutableDictionary *)experiments {
    if (_experiments) {
        return _experiments;
    }
    _experiments = NSMutableDictionary.new;
    return _experiments;
}

- (NSString *)clientID {
    if (_clientID) {
        return _clientID;
    }
    _clientID = [NSUserDefaults.standardUserDefaults objectForKey:@"sixpackClientID"];
    if (!_clientID) {
        _clientID = UIDevice.currentDevice.identifierForVendor.UUIDString;
        if (_clientID) {
            [NSUserDefaults.standardUserDefaults setValue:_clientID forKey:@"sixpackClientID"];
        }
    }
    return _clientID;
}

@end
