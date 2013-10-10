//
//  SGNetworkQueue.m
//  SixpackClient
//
//  Created by James Van-As on 10/10/13.
//  Copyright (c) 2013 SeatGeek Inc. All rights reserved.
//

#import "SGNetworkQueue.h"
#import "SGParticipateOperation.h"
#import "SGPrefetchOperation.h"
#import "SGConvertOperation.h"

@implementation SGNetworkQueue
{
    NSMutableArray *_experimentQueue;
    NSMutableArray *_prefetchQueue;
    BOOL _running;
}

- (id)init {
    self = [super init];
    if (self) {
        _experimentQueue = NSMutableArray.new;
        _prefetchQueue = NSMutableArray.new;
    }
    return self;
}

#pragma mark Network Queues
//our network queue handling runs in the main thread.  Actual work is handled in AFNetworking operation queues
- (void)startQueues {
    if (_running) {
        return;
    }
    _running = YES;
    [self popQueues];
}

- (void)stopQueues {
    if (!_running) {
        return;
    }
    _running = NO;
}

- (void)popQueues {
    /* Run queues in this order:
     1.  prefetchQueue
     2.  experimentQueue
     */
    
    if (!_running) {
        return;
    }
    
    if (_prefetchQueue.count){
        SGSixpackOperation *operation = _prefetchQueue.firstObject;
        [_prefetchQueue removeObject:operation];
        [operation run];
    } else if (_experimentQueue.count) {
        SGSixpackOperation *operation = _experimentQueue.firstObject;
        [_experimentQueue removeObject:operation];
        [operation run];
    } else {
        _running = NO;
        return; //no more work to do
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self popQueues];
    });
}

- (void)cancelPrefetchFor:(SGSixpackExperiment *)experiment {
    SGPrefetchOperation *prefetchToCancel;
    for (SGPrefetchOperation *prefetch in _prefetchQueue) {
        if (prefetch.experiment == experiment) {
            prefetchToCancel = prefetch;
            break;
        }
    }
    
    if (prefetchToCancel) {
        [_prefetchQueue removeObject:prefetchToCancel];
    }
}

- (void)addPrefetchOperationFor:(SGSixpackExperiment *)experiment {
    SGPrefetchOperation *prefetch = SGPrefetchOperation.new;
    prefetch.experiment = experiment;
    prefetch.networkQueue = self;
    [_prefetchQueue addObject:prefetch];
    
    [self startQueues];
}

- (void)addParticipateOperationFor:(SGSixpackExperiment *)experiment {
    SGParticipateOperation *participate = SGParticipateOperation.new;
    participate.experiment = experiment;
    participate.networkQueue = self;
    [_experimentQueue addObject:participate];
    
    [self startQueues];
}

- (void)addConversionOperationFor:(SGSixpackExperiment *)experiment {
    SGConvertOperation *conversion = SGConvertOperation.new;
    conversion.experiment = experiment;
    conversion.networkQueue = self;
    [_experimentQueue addObject:conversion];
    
    [self startQueues];
}


@end
