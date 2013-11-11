//
//  CamFusionDefines.h
//  BrandFusion
//
//  Created by Ronan on 05/11/2013.
//  Copyright (c) 2013 Pimovi. All rights reserved.
//

#ifndef BrandFusion_CamFusionDefines_h
#define BrandFusion_CamFusionDefines_h

extern NSString *const kVzaarPimoviSecret;
extern NSString *const kVzaarPimoviAuthToken;

extern NSString *const kAppId1;
extern NSString *const kGooglePlusClientID;

extern NSString *const kParseAppId;
extern NSString *const kParseClientKey;

#define PiLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#endif
