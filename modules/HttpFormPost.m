//
//  HttpFormPost.m
//  multipost
//
//  Created by naoyuki onishi on 2013/04/17.
//  Copyright (c) 2013年 naoyuki onishi. All rights reserved.
//

#import "HttpFormPost.h"
#import "Reachability.h"

@implementation HttpFormPost

@synthesize boundary = _boundary;
@synthesize url = _url;
@synthesize status_code = _status_code;
@synthesize request_error = _request_error;

- (id)init {
	self = [super init];
	if (self) {
		self->_url = nil;
		self->_boundary = @"_insert_some_boundary_here_";
		self->_response_data = nil;
		self->_response = nil;
		self->_request_error = nil;
		self->_status_code = 0;
		self->_text_list = [[NSMutableArray array] retain];
		self->_file_list = [[NSMutableArray array] retain];
		self->_data_list = [[NSMutableArray array] retain];
	}
	return self;
}


- (void)addText:(NSString *)form_name text:(NSString *)text
{
	NSDictionary *text_dict = [NSDictionary dictionaryWithObjectsAndKeys:
				   form_name, @"form_name",
				   text, @"text",
				   nil];

	[self->_text_list addObject:text_dict];
}


- (void)addFile:(NSString *)form_name file_path:(NSString *)file_path
{
	[self addFile:form_name file_path:file_path file_name:[file_path lastPathComponent] mine_type:@"application/octet-stream"];
}


- (void)addFile:(NSString *)form_name file_path:(NSString *)file_path file_name:(NSString *)file_name
{
	[self addFile:form_name file_path:file_path file_name:file_name mine_type:@"application/octet-stream"];
}


- (void)addFile:(NSString *)form_name file_path:(NSString *)file_path mine_type:(NSString *)mine_type
{
	[self addFile:form_name file_path:file_path file_name:[file_path lastPathComponent] mine_type:mine_type];
}


- (void)addFile:(NSString *)form_name file_path:(NSString *)file_path file_name:(NSString *)file_name mine_type:(NSString *)mine_type
{
	NSDictionary *file_dict = [NSDictionary dictionaryWithObjectsAndKeys:
				   form_name, @"form_name",
				   file_path, @"file_path",
				   file_name, @"file_name",
				   mine_type, @"mine_type",
				   nil];

	[self->_file_list addObject:file_dict];
}


- (void)addData:(NSString *)form_name data:(NSData *)data data_name:(NSString *)data_name
{
	[self addData:form_name data:data data_name:data_name mine_type:@"application/octet-stream"];
}


- (void)addData:(NSString *)form_name data:(NSData *)data data_name:(NSString *)data_name mine_type:(NSString *)mine_type
{
	NSDictionary *data_dict = [NSDictionary dictionaryWithObjectsAndKeys:
				   form_name, @"form_name",
				   data, @"data",
				   data_name, @"data_name",
				   mine_type, @"mine_type",
				   nil];

	[self->_data_list addObject:data_dict];
}


- (NSData *)submit
{
	[self->_response_data release];
	self->_response_data = nil;

	//ネットワーク使用可否チェック
	Reachability *reachability = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reachability currentReachabilityStatus];
	if (NotReachable == status) {
		self->_status_code = NotConnectingToNetworkCode;
		return nil;
	}

	NSMutableData *post_data = [NSMutableData dataWithLength:0];

	//テキスト項目の電文作成
	for (NSDictionary* text_dict in self->_text_list) {

		[post_data appendData:[[NSString stringWithFormat:@"--%@\r\n", self->_boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[post_data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", [text_dict objectForKey:@"form_name"]] dataUsingEncoding:NSUTF8StringEncoding]];
		[post_data appendData:[[text_dict objectForKey:@"text"] dataUsingEncoding:NSUTF8StringEncoding]];
		[post_data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	}


	//ファイル項目の電文作成
	for (NSDictionary *file_dict in self->_file_list) {

		NSData *file_data = [[NSData alloc] initWithContentsOfFile:[file_dict objectForKey:@"file_path"]];
		[post_data appendData:[[NSString stringWithFormat:@"--%@\r\n", self->_boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[post_data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", [file_dict objectForKey:@"form_name"], [file_dict objectForKey:@"file_name"]] dataUsingEncoding:NSUTF8StringEncoding]];
		[post_data appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		[post_data appendData:file_data];
		[post_data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		[file_data release];
	}


	//データ項目の電文作成
	for (NSDictionary *data_dict in self->_data_list) {

		[post_data appendData:[[NSString stringWithFormat:@"--%@\r\n", self->_boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[post_data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", [data_dict objectForKey:@"form_name"], [data_dict objectForKey:@"data_name"]] dataUsingEncoding:NSUTF8StringEncoding]];
		[post_data appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		[post_data appendData:[data_dict objectForKey:@"data"]];
		[post_data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	}

	[post_data appendData:[[NSString stringWithFormat:@"--%@--\r\n\r\n", self->_boundary] dataUsingEncoding:NSUTF8StringEncoding]];

	//リクエストの設定
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self->_url
	                                                       cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
	                                                   timeoutInterval:10];


	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:post_data];
	[request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", self->_boundary] forHTTPHeaderField:@"Content-Type"];

	//サーバーリクエスト
	NSData *response_data = [NSURLConnection sendSynchronousRequest:request returningResponse:&self->_response error:&self->_request_error];


	self->_status_code = self->_response.statusCode;

	//成功時
	if (NULL == self->_request_error) {
		self->_response_data = response_data;
	}

	return self->_response_data;

}

- (void)dealloc
{
	[self->_url release];
	[self->_boundary release];
	[self->_text_list release];
	[self->_file_list release];
	[self->_data_list release];
	[super dealloc];
}

@end
