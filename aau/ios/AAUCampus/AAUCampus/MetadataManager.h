//
//  MetadataManager.h
//  AAU Hybrid
//
//  Created by Marlin Scott on 8/1/12.
//
//

#import <Foundation/Foundation.h>

@interface MetadataManager : NSObject{
    NSDictionary *teletracCreds;
    NSMutableData *receivedData;
    
    BOOL retrievingCreds;

}

@property (nonatomic, strong) NSDictionary *teletracCreds;
@property (nonatomic, strong) NSMutableData *receivedData;



+ (MetadataManager *)sharedManager;

- (void)getTeletracCredentials;

@end
