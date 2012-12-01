

$(document).ready(function()
{
// Logging - Disable in production
//Pusher.log = function() { if (window.console) window.console.log.apply(window.console, arguments); };


// Global variable "channel" is set in the view
var pusher = new Pusher('9ceb5ef670c4262bfbca');
Pusher.channel_auth_endpoint = '/api/authenticate';
var ensembleChannel = pusher.subscribe(channel_name);
var url;
var urlRegex = /(https?\:\/\/|\s)[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})(\/+[a-z0-9_.\:\;-]*)*(\?[\&\%\|\+a-z0-9_=,\.\:\;-]*)?([\&\%\|\+&a-z0-9_=,\:\;\.-]*)([\!\#\/\&\%\|\+a-z0-9_=,\:\;\.-]*)}*/i;
var images;
var currentImageIndex = -1;

// Deal with incoming messages!
ensembleChannel.bind('post_comment', function(comment) {
  var comment_class, display_name, suggestion_button = '';

  if(comment.commentable_type == 'User'){
    //User comment
    comment_class = 'alert alert-error';
    suggestion_button = '<a class="btn btn-small pull-right" href="#" data-toggle="modal" data-target="#add-preference-modal"><i class=" icon-plus pull-right"></i></a>';
    display_name = 'Requester'
  } else if(comment.commentable_type == 'Turk' && turk_id == comment.commentable_id) {
    //My Comment
    comment_class = 'alert alert-success'; 
    display_name = 'Me'
  } else {
    //Another Turker's comment
    comment_class = 'alert alert-info';
    display_name = 'Fashionista'+comment.commentable_id;
  }
  console.log(comment.body)
  console.log($('#chat-messages ul'))
  $('#chat-messages ul').append('<li class="message"><div class ="'+ comment_class +'"><p>' + suggestion_button +'<strong>' + display_name + '</strong>: ' + replaceURLWithHTMLLinks(comment.body) + '</p></div></li>');
  scrollToTheTop();
});

ensembleChannel.bind('post_suggestion', function(suggestion) {
  var list_item = getSuggestionBullet(suggestion);
  $('#suggestion-list').append(list_item);
  scrollToTheTop();
});

ensembleChannel.bind('update_sent_suggestion', function(suggestion) {
	alert_div = "<div class='span11 alert alert-error'><h4>Waiting on response...</h4>";
	alert_div += "Please wait for the requestor to respond before peforming any actions</div>";
	$('.suggestion-alert').append(alert_div);
});


ensembleChannel.bind('update_suggestions', function(suggestions) {
  $('.suggestion').remove();
  var ii;
  var list_item;
  for (ii = 0; ii < suggestions.length; ++ii) {
      suggestion = suggestions[ii];
      list_item = getSuggestionBullet(suggestion);
      $('#suggestion-list').append(list_item);    
  }
});

ensembleChannel.bind('update_preferences', function(preferences) {
  $('.preference').remove();
  var ii;
  var list_item;
  for (ii = 0; ii < preferences.length; ++ii) {
      pref = preferences[ii];
      list_item = "<li class='span5 preference'><p>" + pref.body;
      list_item += "<a  href='#'><i class='icon-remove remove-pref-icon' value='";
      list_item += pref.id+"'></i></a></p></li>";
      $('#preference-list').append(list_item);    
  }
});

function getSuggestionBullet(suggestion){
	list_item = '<li class="suggestion"><div class="row"><div class="span1">';
  	list_item += '<p><img alt="" id="suggestion-img" src="'+suggestion.image_url+'"/></p>';
  	list_item += '</div> <div class="span3"><a href="'+suggestion.product_url;
  	list_item += '" target="_blank"><p><b>'+suggestion.product_name+'</b></p></a>';
	list_item += '<p>'+suggestion.retailer+'</p><p>$'+suggestion.price+'</p>';
	list_item +='<button class="btn btn-mini upvote"><i class="icon-thumbs-up"><input type="hidden" value="'+suggestion.id+'"/></i>';
	list_item += '</button><button class="btn btn-mini downvote"><i class="icon-thumbs-down"><input type="hidden" value="'+suggestion.id+'"/></i>';
	list_item += '</button><span class="badge badge-success">'+suggestion.vote_count+'</span></div></div></li>';
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

$('.remove-pref-icon').live("click",function(){
    remove_pref($(this).attr("value"));
});


$('#comment-btn').click(function(){
    post_comment();
});

$('#suggest-btn').click(function(){
    post_suggestion();
});
$('#create-preference-modal-btn').click(function(){
	post_preference();
});

function trim(str) {
	return str.replace(/^\s+|\s+$/g,"");
}


$('#create-suggestion-product-link').blur(function()
{
	if( trim($(this).val() ) != ""){
		url = $(this).val();
		if(urlRegex.test(url)){
			$('#create-suggestion-img').attr('src','/loader.gif');	
			$.get('/preview?url='+url, function(response){
				images = response.images;
				currentImageIndex = 0;
				var imgSrc = images[currentImageIndex];
				$('#create-suggestion-img').attr("src",imgSrc);
			});	
		}
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