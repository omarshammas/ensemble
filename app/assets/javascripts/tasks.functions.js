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
	// Validate Field
	//TODO: Only post if is a URL
	if($('#chat-text-input').val() == '') {
		alert('Please enter text...');
		$('#chat-text-input').focus();
		return false;
	}
	var body = $('#chat-text-input').val();
	$.post('/api/post_suggestion', { "task_id": channel, "body":body }, function(response) {
		$('#chat-text-input').val("");
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