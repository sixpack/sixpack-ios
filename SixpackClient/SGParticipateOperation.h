//
//  SGParticipateOperation.h
//  SixpackClient
//
//  Created by James Van-As on 10/10/13.
//  Copyright (c) 2013 SeatGeek Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGSixpackOperation.h"

@class SGSixpackExperiment, SGNetworkQueue;

@interface SGParticipateOperation : NSObject <SGSixpackOperation>

@property (weak) SGSixpackExperiment *experiment;
@property (weak) SGNetworkQueue *networkQueue;

@end
