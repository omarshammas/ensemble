$(document).ready(function(){

// Global variable "channel" is set in the view
var pusher = new Pusher('9ceb5ef670c4262bfbca');
Pusher.channel_auth_endpoint = '/api/authenticate';
var ensembleChannel = pusher.subscribe(channel_name);
var url;
var urlRegex = /(https?\:\/\/|\s)[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})(\/+[a-z0-9_.\:\;-]*)*(\?[\&\%\|\+a-z0-9_=,\.\:\;-]*)?([\&\%\|\+&a-z0-9_=,\:\;\.-]*)([\!\#\/\&\%\|\+a-z0-9_=,\:\;\.-]*)}*/i;
var images;
var currentImageIndex = -1;


ensembleChannel.bind('update_sent_suggestion', function(suggestion) {
  $('.suggestion-alert').empty();
  alert_div = "<div class='span11 alert alert-error'><h4>Waiting on response...</h4>";
  alert_div += "Please wait for the requestor to respond before peforming any actions</div>";
  $('.suggestion-alert').append(alert_div);
});

ensembleChannel.bind('suggestion_rejected', function(suggestion) {
  $('.suggestion-alert').empty();
  var list_item = getHistoryBullet(suggestion);
  $('#history-box-second').prepend(list_item);
});

ensembleChannel.bind('suggestion_accepted', function(suggestion) {
  $('.suggestion-alert').empty();
  task_alert = "<div class='span12 alert-block alert alert-success'>";
  task_alert += "<h4>Task complete</h4>";
  task_alert += "This task is complete and requires no more work</div>";
  $('.task-alert').append(task_alert);
  $('.task-components').empty();
});

ensembleChannel.bind('post-suggestion-second'), function(suggestion) {
  var list_item = getSuggestionBullet(suggestion);
  $('#suggestions-box-second').append(list_item);
  scrollToTheTop();
});

ensembleChannel.bind('update_suggestions', function(suggestions) {
  $('.suggestion-item').remove();
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

  var list_item = "<div class='history-item row-fluid'><div class = 'span6 thumbnail rating"+suggestion.rating;
  list_item += "'><img class='prev-suggestion-img' src='"+ history.image_url +"'/></div>";
  list_item += "<div class='desc span5'>" + history.body + "</div></div>";
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




});