//
//  SGPrefetchOperation.m
//  SixpackClient
//
//  Created by James Van-As on 10/10/13.
//  Copyright (c) 2013 SeatGeek Inc. All rights reserved.
//

#import "SGPrefetchOperation.h"
#import "AFNetworking/AFNetworking.h"
#import "SGSixpackExperiment.h"
#import "SGNetworkQueue.h"

@implementation SGPrefetchOperation

- (void)run {
    NSMutableDictionary *parameters = @{@"client_id" : self.experiment.clientID,
                                 @"experiment" : self.experiment.name,
                                 @"alternatives" : self.experiment.alternatives }.mutableCopy;

    if (self.experiment.forcedAlternative) {
        parameters[@"force"] = self.experiment.forcedAlternative;
    }
    parameters[@"prefetch"] = @"true";
    
    [self.experiment.operationManager GET:[SGSixpackOperation urlForBase:[self.experiment.url stringByAppendingString:@"participate"]
                                                              parameters:parameters]
                               parameters:nil
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        SGSixpackDebugLog(@"Sixpack Prefetch Response: %@", responseObject);
        if (responseObject[@"alternative"]) {
            self.experiment.chosenAlternative = responseObject[@"alternative"][@"name"];
            if (!self.experiment.setupCompleteBlockCalled && self.experiment.setupCompleteBlock) {
                self.experiment.setupCompleteBlockCalled = YES;
                self.experiment.setupCompleteBlock();
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        SGSixpackDebugLog(@"Sixpack Prefetch Error: %@", error);
        if (self.experiment.operationManager.reachabilityManager.reachable) {
            //give up
            if (self.experiment.forcedAlternative) {
                self.experiment.chosenAlternative = self.experiment.forcedAlternative;
            } else {
                self.experiment.chosenAlternative = self.experiment.alternatives.firstObject;
            }
        } else {
            //add ourselves back to the queue.  Try again later.
            SGSixpackDebugLog(@"Network appears to be offline. Queuing Prefetch for later");
            [self.networkQueue addPrefetchOperationFor:self.experiment];
        }
        //call the completion block.  We don't want to hold up any possible GUI
        if (!self.experiment.setupCompleteBlockCalled && self.experiment.setupCompleteBlock) {
            self.experiment.setupCompleteBlockCalled = YES;
            self.experiment.setupCompleteBlock();
        }
    }];

    if (self.experiment.setupCompleteBlock && self.experiment.setupCompleteBlockTimeout > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.experiment.setupCompleteBlockTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!self.experiment.setupCompleteBlockCalled) {
                self.experiment.setupCompleteBlockCalled = YES;
                self.experiment.setupCompleteBlock();
            }
        });
    }
}

@end
