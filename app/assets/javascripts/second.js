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

ensembleChannel.bind('update_suggestions', function(suggestions) {
  $('#suggestions-box-second').empty();
  var list_item;
  var items_per_row = 3;
  for (var ii = 0; ii < suggestions.length; ++ii) {
      suggestion = suggestions[ii];
      list_item = getSuggestionBullet(suggestion);

      if (ii%items_per_row == 0){
        $('#suggestions-box-second').append("<div class='row-fluid suggestion-row'>");        
      }

      $('#suggestions-box-second .suggestion-row').last().append(list_item);    

      if ((ii%items_per_row == items_per_row-1) || (ii >= suggestions.length-1)){
        $('#suggestions-box-second').append("</div>");
      }
  }
});

function getSuggestionBullet(suggestion){
  var list_item = "<div class='suggestion-item-second span4 thumbnail' data-suggestion-id='"+suggestion.id+"'>";
  list_item += "<img class='suggestion-img-second' src='"+ suggestion.image_url +"' />";
  list_item += "<p><a href='" + suggestion.product_link + "' target='blank'><b>"+ suggestion.product_name +"</b></a><br />";
  list_item += suggestion.price + "<br />" + suggestion.retailer + "<br />";
  list_item += "<span class='badge badge-success' id='vote_count_" + suggestion.id;
  list_item += "'>" + suggestion.vote_count + "</span></p></div>";
 	return list_item;
}

function getHistoryBullet(history){
  var list_item = "<div class='row-fluid history-item-second' data-history-id='"+history.id+"'>";
  list_item += "<div class = 'span5 thumbnail rating"+ history.rating + "'>";
  list_item += "<img class='history-img-second' src='"+ history.image_url +"'/>";
  list_item += "<p><a href='" + history.product_link + "' target='_blank'>";
  list_item += "<b>" + history.product_name + "</b></a><br />";
  list_item += history.price + "<br />" + history.retailer + "<br />";
  list_item += "</p></div><div class='span7 desc'>" + history.body + "</div></div>";
  return list_item;
}

$('.upvote').live('click',function(){
    var suggestion_id = $(this).children().find('input[type="hidden"]');
    post_up_vote(suggestion_id.val());
});

$('.downvote').live('click',function(){
    var suggestion_id = $(this).children().find('input[type="hidden"]');
    post_down_vote(suggestion_id.val());
});

$('#pro-btn').live('click', function(){
  makePoint(true);
});

$('#con-btn').live('click', function(){
  makePoint(false);
});

$('#comment-btn').click(function(){
    post_comment();
});

$('#suggest-btn').click(function(){
    post_suggestion();
});

$('.suggestion-item-second').live('click', function(){
  var suggestion_id = $(this).attr('data-suggestion-id');
  get_suggestion(suggestion_id);
});

$('.history-item-second').live('click', function(){
  var history_id = $(this).attr('data-history-id');
  get_suggestion(history_id);
});

function trim(str) {
	return str.replace(/^\s+|\s+$/g,"");
}


$('#create-suggestion-product-link').blur(function(){
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