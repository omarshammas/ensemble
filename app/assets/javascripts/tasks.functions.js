function post_comment() {
	// Validate Field
	if($('#chat-text-input').val() == '') {
		alert('Please enter text...');
		$('#chat-text-input').focus();
		return false;
	}
	var body = $('#chat-text-input').val();
	// Post off to the server with the message and some vars!
	$.post('/api/post_comment', { "task_id": channel, "body":body }, function(response) {
		$('#chat-text-input').val("");
	});
}

function post_suggestion() {
	var image_url = $('#create-suggestion-img-url').attr('src');
	var retailer = $('#create-suggestion-retailer').val();
	var product_name = $('#create-suggestion-product-name').val();
	var product_link = $('#create-suggestion-product-link').val();
	var price = $('#create-suggestion-product-price').val(); 
	//Return if all fields aren't filled out
	if(!image_url || !retailer || !product_name || !product_link || !price) {
		alert('Please fill out all fields');
		return false;
	}
	//Post suggestion
	$.post('/api/post_suggestion', { "task_id": channel, "image_url": image_url, "retailer": retailer, 
		"product_name": product_name, "product_link": product_link, "price": price}, function(response) {
	});
}

function post_preference(){
	var body = $('#create-preference-modal-textarea').val();
	$.post('/api/post_preference', {"preference_body": body, "task_id": channel}, function(response) {
	});
}

function post_up_vote(suggestion_id) {
	//TODO: Only post if is a URL
	$.post('/api/post_up_vote', {"suggestion_id": suggestion_id}, function(response) {
	});
}

function post_down_vote(suggestion_id) {
	//TODO: Only post if is a URL
	$.post('/api/post_down_vote', {"suggestion_id": suggestion_id}, function(response) {
	});
}

function scrollToTheTop() {
	$("#chat-messages").scrollTop(20000000);
}

function replaceURLWithHTMLLinks(text) {
     var exp = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[.\!\/\\w]*))?)/;
     return text.replace(exp,"<a href='$1' target='_blank'>$1</a>");
}