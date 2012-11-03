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


function scrollToTheTop() {
$("#messages").scrollTop(20000000);
}

function replaceURLWithHTMLLinks(text) {
     var exp = /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig;
     return text.replace(exp,"<a href='$1' target='_blank'>$1</a>");
}