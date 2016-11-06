	HttpFormPost * ins = [[HttpFormPost alloc] init];

	//post先urlの設定
	ins.url = [NSURL URLWithString:@"http://gifu-sk.aa2.netvolante.jp/HttpFormPost-test/test.php"];

	//boundaryの設定
	ins.boundary = @"---tekitou--tekitou--tekitou---";

	//テキストの追加
	[ins addText:@"message1" text:@"あいうえお"];
	[ins addText:@"message2" text:@"かきくけこ"];

	//ファイルパスからデータの追加
	NSString *file_path = [[NSBundle mainBundle] pathForResource:@"image" ofType:@"jpg"];
	[ins addFile:@"upload_file[]" file_path:file_path file_name:@"image.jpg"];

	//データより追加
	NSData *image_data = UIImagePNGRepresentation(self->_image_view.image);
	[ins addData:@"upload_file[]" data:image_data data_name:@"image_by_data.png"];

	//データ送信実行
	NSData *response_data = [ins submit];


	/**
	 * メッセージ表示
	 */
	UIAlertView *alertResult;
	NSString *response = nil;
	NSString *title = nil;
	NSString *message = nil;
	if (nil != response_data) {

		//レスポンスがjsonの場合
		//NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response_data
		//						     options:NSJSONReadingAllowFragments
		//						       error:nil];

		//レスポンスがxmlの場合
		//NSError *error = nil;
		//NSDictionary *dict = [XMLReader dictionaryForXMLData:response_data error:&error];


		//サーバーから送られた文字列の確認
		response = [[NSString alloc] initWithData:response_data encoding:NSUTF8StringEncoding];
		NSLog(@"response=[%@]", response);

		//成功時
		if ([response isEqualToString:@"success"]){
			title = @"success title";
			message =  @"your success message";
		}
		//PHPエラー
		else {
			title = @"error title";
			message =  @"your error message";
		}
	}
	else {
		title = @"error title";

		//3GにもWifiにも繋がっていない
		if (NotConnectingToNetworkCode == ins.status_code) {
			message =  @"not connectiong to network";
		}

		//通信エラー
		else {
			message = [[NSString alloc] initWithString:[ins.request_error localizedDescription]];
		}
	}

	//メッセージ表示
	alertResult = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
	[alertResult show];
