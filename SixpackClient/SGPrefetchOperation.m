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
    
    [self.experiment.operationManager GET:@"/participate"
                               parameters:parameters
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Sixpack Prefetch Response: %@", responseObject);
        if (responseObject[@"alternative"]) {
            self.experiment.chosenAlternative = responseObject[@"alternative"][@"name"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Sixpack Prefetch Error: %@", error);
        if (self.experiment.operationManager.reachabilityManager.reachable) {
            //give up
            if (self.experiment.forcedAlternative) {
                self.experiment.chosenAlternative = self.experiment.forcedAlternative;
            } else {
                self.experiment.chosenAlternative = self.experiment.alternatives.firstObject;
            }
        } else {
            //add ourselves back to the queue.  Try again later.
            NSLog(@"Network appears to be offline. Queuing Prefetch for later");
            [self.networkQueue addPrefetchOperationFor:self.experiment];
        }
    }];
}

@end
