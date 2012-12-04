$(document).ready(function(){

// Global variable "channel" is set in the view
var pusher = new Pusher('9ceb5ef670c4262bfbca');
Pusher.channel_auth_endpoint = '/api/authenticate';
var ensembleChannel = pusher.subscribe("presence-"+channel_name);
var url;
var urlRegex = /(https?\:\/\/|\s)[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})(\/+[a-z0-9_.\:\;-]*)*(\?[\&\%\|\+a-z0-9_=,\.\:\;-]*)?([\&\%\|\+&a-z0-9_=,\:\;\.-]*)([\!\#\/\&\%\|\+a-z0-9_=,\:\;\.-]*)}*/i;
var images;
var currentImageIndex = -1;
var count=0;

// Logging - Disable in production
Pusher.log = function() { if (window.console) window.console.log.apply(window.console, arguments); };


ensembleChannel.bind('pusher:subscription_succeeded', function(members) {
  console.log(members);
  count = members.count;
  $('#chat-box').find('h4').empty()
  $('#chat-box').find('h4').append("Chat with "+(count-1)+" other Fashionista(s)");
  // members.each(function(member) {
    // // for example:
    // add_member(member.id, member.info);
  // });
});

ensembleChannel.bind('pusher:member_added', function(member) {
  count++;
  $('#chat-box').find('h4').empty()
  $('#chat-box').find('h4').append("Chat with "+ (count-1) +" other Fashionista(s)");
});

ensembleChannel.bind('pusher:member_removed', function(member) {
  count--;
  $('#chat-box').find('h4').empty()
  $('#chat-box').find('h4').append("Chat with "+ (count-1) +" other Fashionista(s)");
});

ensembleChannel.bind('display_redeem_code', function(member){
	
});

// Deal with incoming messages!
ensembleChannel.bind('post_comment', function(comment) {
  var comment_class, display_name, suggestion_button = '';
  if(comment.commentable_type == 'User'){
    //User comment
    comment_class = 'alert alert-error';
    suggestion_button = '<a class="btn btn-small pull-right" href="#" data-toggle="modal" data-target="#add-preference-modal"><i class=" icon-plus pull-right"></i></a>';
    display_name = 'Requestor'
  } else if(comment.commentable_type == 'Turk' && turk_id == comment.commentable_id) {
    //My Comment
    comment_class = 'alert alert-success'; 
    display_name = 'Me'
  } else {
    //Another Turker's comment
    comment_class = 'alert alert-info';
    display_name = 'Fashionista'+comment.commentable_id;
  }
  $('#chat-messages ul').append('<li class="message"><div class ="'+ comment_class +'"><p>' + suggestion_button +'<strong>' + display_name + '</strong>: ' + replaceURLWithHTMLLinks(comment.body) + '</p></div></li>');
  scrollToTheTop();
});

ensembleChannel.bind('post_suggestion', function(suggestion) {
  var list_item = getSuggestionBullet(suggestion);
  $('#suggestions-box').append(list_item);
  scrollToTheTop();
});

ensembleChannel.bind('update_sent_suggestion', function(suggestion) {
  $('.suggestion-alert').empty();
	alert_div = "<div class='span11 alert alert-error'><h4>Waiting on response...</h4>";
	alert_div += "Please wait for the requestor to respond before peforming any actions</div>";
	$('.suggestion-alert').append(alert_div);
});

ensembleChannel.bind('suggestion_rejected', function(suggestion) {
	$('#no-history').empty();
	$('.suggestion-alert').empty();
	var list_item = getHistoryBullet(suggestion);
	$('#history-box').prepend(list_item);
});

ensembleChannel.bind('suggestion_accepted', function(suggestion) {
	$('.suggestion-alert').empty();
	task_alert = "<div class='span12 alert-block alert alert-success'>";
	task_alert += "<h4>Task complete</h4>";
	task_alert += "This task is complete and requires no more work</div>";
	$('.task-alert').append(task_alert);
	$('.task-components').empty();
});


ensembleChannel.bind('update_suggestions', function(suggestions) {
  $('#suggestions-box').empty();
  var ii;
  var list_item;
  for (ii = 0; ii < suggestions.length; ++ii) {
      suggestion = suggestions[ii];
      list_item = getSuggestionBullet(suggestion);
      $('#suggestions-box').append(list_item);    
  }
});

function getSuggestionBullet(suggestion){
  var list_item = "<div class='suggestion-item row-fluid'><div class = 'span6 thumbnail'>"
  list_item += "<img alt='' class='prev-suggestion-img' src='"+ suggestion.image_url +"'/></div>";
  list_item += "<div class='desc span5'><a href='" + suggestion.product_link + "' target='_blank'>";
  list_item += "<b>" + suggestion.product_name + "</b></a><br />";
  list_item += "$" + suggestion.price + "<br />";
  list_item +=  suggestion.retailer + "<br />";
  list_item += "<button class='btn btn-mini upvote'><i class='icon-thumbs-up'><input type='hidden' value='"+ suggestion.id +"'/></i></button>";
  list_item += "<button class='btn btn-mini downvote'><i class='icon-thumbs-down'><input type='hidden' value='"+ suggestion.id +"'/></i></button>";
  list_item += "<span class='badge badge-success' id='vote_count_"+ suggestion.id +"'>"+ suggestion.vote_count +"</span>"; 
  list_item += "</div></div>"
 	return list_item;
}

function getHistoryBullet(history){
  var list_item = "<div class='history-item row-fluid'><div class='row-fluid'><div class='span11'>";
  list_item += "<p><a target='_blank' href='"+history.product_link;
  list_item += "'><img class='history-img pull-left thumbnail rating"+history.rating+"' src='"; 
  list_item += history.image_url +"'/></a>"+history.body+"</p></div></div><div class='row-fluid'>";
  for(ii = 1; ii <= 5; ii++){
  	if( ii <= history.rating)
  		list_item += "<i class='icon-star'></i>";
  	else
  		list_item += "<i class='icon-star-empty'></i>";
  }
  list_item += "</div></div><hr/>"
  return list_item;
}

$('.upvote').live("click",function(){
    var suggestion_id = $(this).children().find('input[type="hidden"]');
    post_up_vote(suggestion_id.val());
});

$('.downvote').live("click",function(){
    var suggestion_id = $(this).children().find('input[type="hidden"]');
    post_down_vote(suggestion_id.val());
});

$('#comment-btn').click(function(){
    post_comment();
});

$('#suggest-btn').click(function(){
    post_suggestion();
});

$('#redeem-btn').click(function(){
  var task_id = $(this).attr('data-task-id');
  get_redeem_code(task_id);
});


function trim(str) {
	return str.replace(/^\s+|\s+$/g,"");
}


$('#create-suggestion-product-link').blur(function(){
	if( trim($(this).val() ) != ""){
		url = $(this).val();
			$('#create-suggestion-img').attr('src','/loader.gif');	
			$.get('/preview?url='+url, function(response){
				images = response.images;
				currentImageIndex = 0;
				var imgSrc = images[currentImageIndex];
				$('#create-suggestion-img').attr("src",imgSrc);
			});	
	}
	return false;
});



$('#suggestion-img-left').click(function(){
	if(currentImageIndex > 0){
		currentImageIndex--;
		var imgSrc = images[currentImageIndex];
		$('#create-suggestion-img').attr("src",images[currentImageIndex]);
		$('#create-suggestion-img-url').attr("src",imgSrc);
	}
});

$('#suggestion-img-right').click(function(){
	if(currentImageIndex < (images.length - 1) ){
		currentImageIndex++;
		var imgSrc = images[currentImageIndex];
		$('#create-suggestion-img').attr("src",images[currentImageIndex]);
		$('#create-suggestion-img-url').attr("src",imgSrc);
	}
});



});