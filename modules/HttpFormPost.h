//
//  HttpFormPost.h
//  multipost
//
//  Created by naoyuki onishi on 2013/04/17.
//  Copyright (c) 2013年 naoyuki onishi. All rights reserved.
//
#define NotConnectingToNetworkCode 999

#import <Foundation/Foundation.h>

@interface HttpFormPost : NSObject
{

@private
	NSURL *_url;
	NSString *_boundary;
	NSData *_response_data;
	NSHTTPURLResponse *_response;
	NSError *_request_error;
	long status_code;

	NSMutableArray *_text_list;
	NSMutableArray *_file_list;
	NSMutableArray *_data_list;
}

@property (nonatomic, retain) NSString *boundary;
@property (nonatomic, retain) NSURL *url;
@property (readonly) int status_code;
@property (nonatomic, assign, readonly) NSError *request_error;

- (void)addText:(NSString *)form_name text:(NSString *)text;
- (void)addFile:(NSString *)form_name file_path:(NSString *)file_path;
- (void)addFile:(NSString *)form_name file_path:(NSString *)file_path file_name:(NSString *)file_name;
- (void)addFile:(NSString *)form_name file_path:(NSString *)file_path mine_type:(NSString *)mine_type;
- (void)addFile:(NSString *)form_name file_path:(NSString *)file_path file_name:(NSString *)file_name mine_type:(NSString *)mine_type;
- (void)addData:(NSString *)form_name data:(NSData *)file_data data_name:(NSString *)data_name;
- (void)addData:(NSString *)form_name data:(NSData *)file_data data_name:(NSString *)data_name mine_type:(NSString *)mine_type;
- (NSData *)submit;

@end
