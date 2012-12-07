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
	$.post('/api/post_up_vote', {"suggestion_id": suggestion_id}, function(response) {
		if (response['status'] == 'already_voted')
			vote_already_cast();
		else if (response['status'] == 'waiting-for-response')
			waiting_for_response();
	});
}

function post_down_vote(suggestion_id) {
	$.post('/api/post_down_vote', {"suggestion_id": suggestion_id}, function(response) {
		if (response['status'] == 'already_voted')
			vote_already_cast();
		else if (response['status'] == 'waiting-for-response')
			waiting_for_response();
	});
}


function makePoint(isPro){
  var point = $('#procon-text-input').val();
  if (point.trim() == ''){
    alert("If you want to add a con or pro it can't be blank");
  } else {
    var suggestion_id = $('#procon-text-input').attr('data-suggestion-id');
    $('#procon-text-input').val('');
    post_point(suggestion_id, isPro, point);
  }
}

function post_point(suggestion_id, isPro, point){
	$.post('/api/post_point', {"suggestion_id": suggestion_id, 'isPro':isPro, 'body':point}, function(response) {
	});
}

function get_redeem_code(task_id){
	$.post('/api/get_redeem_code', {"task_id": task_id }, function(response) {
		if (response['status'] == 'success'){
			alert(response['code'] + ' - THIS WILL BE SHOWN ONCE. PLEASE MAKE SURE YOU WRITE THIS DOWN!');
		} else {
			alert('You have completed '+response['count']+' out of the ' + response['min_tasks'] + ' tasks required to claim your redeem code.');
		}
	});
}

function get_suggestion(suggestion_id){
	$.post('/api/get_suggestion', {"suggestion_id": suggestion_id}, function(response) {
		var suggestion = $.parseJSON(response['suggestion']);
		var pros = $.parseJSON(response['pros']);
		var cons = $.parseJSON(response['cons']);
		//modal header
		$('#procon-modal-label').empty();
		$('#procon-modal-label').append("$"+suggestion['price']+" "+suggestion['product_name']);
		//modal pros
		$('#pros ul').empty();
		$('#pros ul').attr('name',suggestion.id);
		for(var ii=0; ii < pros.length; ++ii){
			$('#pros ul').append("<li>"+pros[ii]['body']+"</li>");
		}
		//modal cons
		$('#cons ul').empty();
		$('#cons ul').attr('name',suggestion.id);
		for(var ii=0; ii < cons.length; ++ii){
			$('#cons ul').append("<li>"+cons[ii]['body']+"</li>");
		}

		$('#procon-input').empty();
		if (!suggestion['sent']){
			$('#procon-input').append("<button class='btn btn-success' id='pro-btn'>Pro</button>");
			$('#procon-input').append("<textarea rows='2' span='12' id='procon-text-input' data-suggestion-id='"+suggestion['id']+"'></textarea>");
			$('#procon-input').append("<button class='btn btn-danger' id='con-btn'>Con</button>");
		}

		//modal body
		$('#suggestion-modal').empty();
		$('#suggestion-modal').append("<img src='"+suggestion['image_url']+"' />");
		$('#suggestion-modal').append("<p></p>");
		$('#suggestion-modal p').append("<a href='"+suggestion['product_link']+"' target='_blank'><b>"+suggestion['product_name']+"</b></a><br />");
		$('#suggestion-modal p').append("$"+suggestion['price']+"<br />"+suggestion['retailer']+"<br />");
		$('#suggestion-modal p').append("<span class='badge badge-success' id='vote_count_"+suggestion['id']+"''>"+suggestion['vote_count']+"</span>");
		
		$('#procon-footer').empty();
		if(!suggestion['sent']){ //modal footer vote buttons
			$('#procon-footer').append("<button class='btn upvote'><i class='icon-thumbs-up'><input type='hidden' value='"+suggestion['id']+"'/></i></button>");
			$('#procon-footer').append("<button class='btn downvote'><i class='icon-thumbs-down'><input type='hidden' value='"+suggestion['id']+"'/></i></button>");
		}
		$('#procon-footer').append("<button class='btn' data-dismiss='modal' aria-hidden='true'>Close</button>");
		$('#procon-modal').modal('show');
	});
}

function replaceURLWithHTMLLinks(text) {
     var exp = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[.\!\/\\w]*))?)/;
     return text.replace(exp,"<a href='$1' target='_blank'>$1</a>");
}

function vote_already_cast(){
	alert("You have already voted on this suggestion.");
}

function waiting_for_response(){
	alert("You can't vote until the requestor responds");
}