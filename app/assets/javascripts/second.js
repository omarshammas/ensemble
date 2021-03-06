$(document).ready(function(){

// Global variable "channel" is set in the view
var pusher = new Pusher('9ceb5ef670c4262bfbca');
Pusher.channel_auth_endpoint = '/api/authenticate';
var ensembleChannel = pusher.subscribe(channel_name);
var url;
var urlRegex = /(https?\:\/\/|\s)[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})(\/+[a-z0-9_.\:\;-]*)*(\?[\&\%\|\+a-z0-9_=,\.\:\;-]*)?([\&\%\|\+&a-z0-9_=,\:\;\.-]*)([\!\#\/\&\%\|\+a-z0-9_=,\:\;\.-]*)}*/i;
var images;
var currentImageIndex = -1;

$("#suggestion-img-nav").hide();
//Pusher.log = function() { if (window.console) window.console.log.apply(window.console, arguments); };

ensembleChannel.bind('update_sent_suggestion', function(suggestion) {
  $('.suggestion-alert').empty();
  alert_div = "<div class='span11 alert alert-error'><h4>Waiting on response...</h4>";
  alert_div += "Please wait for the requestor to respond before peforming any actions</div>";
  $('.suggestion-alert').append(alert_div);
});

ensembleChannel.bind('point_added', function(point) {
	if (point['isPro']) {
		$('#pros').find('ul[name="'+point.suggestion_id+'"]').append("<li>" + point.body + "</li>");
	} else {
		$('#cons').find('ul[name="'+point.suggestion_id+'"]').append("<li>" + point.body + "</li>");
	}
});

ensembleChannel.bind('suggestion_rejected', function(suggestion) {
  $('.suggestion-alert').empty();
  var list_item = getHistoryBullet(suggestion);

  var count = $('#history-box-second .history-item-second').length;
  if (count == 0){
    $('#history-box-second').empty()
  }
  $('#history-box-second').prepend(list_item);
});

ensembleChannel.bind('suggestion_accepted', function(suggestion) {
  $('.suggestion-alert').empty();
  task_alert = "<div class='span12 alert-block alert alert-success'>";
  task_alert += "<h4>Task complete</h4>";
  task_alert += "This task is complete and requires no more work</div>";
  $('.task-alert').append(task_alert);
  $('.task-components').empty();
  //Show redeem code
  $.post('/api/get_redeem_code', {"task_id": suggestion.task_id }, function(response) {
	var code = response['code'];
	$('#redeem-code').empty();
	$('#redeem-code').append('<p><b>Redeem Code:</b> ' + code + '<br/><br/>PLEASE WRITE THIS DOWN NOW! IT WILL DISAPPEAR ON A REFRESH!</p>');
  });
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
      $('#suggestion-modal p #vote_count_'+suggestion.id).empty();
      $('#suggestion-modal p #vote_count_'+suggestion.id).append(suggestion.vote_count);

      if ((ii%items_per_row == items_per_row-1) || (ii >= suggestions.length-1)){
        $('#suggestions-box-second').append("</div>");
      }
  }
});

function getSuggestionBullet(suggestion){
  var list_item = "<div class='suggestion-item-second span4 thumbnail' data-suggestion-id='"+suggestion.id+"'>";
  list_item += "<img class='suggestion-img-second' src='"+ suggestion.image_url +"' />";
  list_item += "<p><b>"+ suggestion.product_name +"</b><br />$";
  list_item += suggestion.price + "<br />" + suggestion.retailer + "<br />";
  list_item += "<span class='badge badge-success' id='vote_count_" + suggestion.id;
  list_item += "'>" + suggestion.vote_count + "</span></p></div>";
 	return list_item;
}

function getHistoryBullet(history){
  var list_item = "<div class='row-fluid history-item-second' data-history-id='"+history.id+"'>";
  list_item += "<div class='span6'> <a href='"+ history.product_link+"' target='_blank'>"
  list_item += "<img src='"+ history.image_url +"' class='";
  list_item += "thumbnail history-img-second rating"+history.rating+"'/></a>";
  list_item += "<p><a href='" + history.product_link + "' target='_blank'>"
  list_item += "<b>" + history.product_name + "</b></a><br />";
  list_item += history.price + "<br />" + history.retailer + "<br />";
  list_item += "</p></div><div class='span6 desc'><p>" + history.body + "</p><hr />";
  for(ii = 1; ii <= 5; ii++){
  	if( ii <= history.rating)
  		list_item += "<i class='icon-star'></i>";
  	else
  		list_item += "<i class='icon-star-empty'></i>";
  }
  list_item += "</div></div>"
  console.log(list_item);
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

$('#redeem-btn').click(function(){
  var task_id = $(this).attr('data-task-id');
  get_redeem_code(task_id);
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

$('#create-suggestion-product-link').focus(function() {
	$("#suggestion-img-nav").hide();
	$("#suggestion-img-count").text("");
	$("#suggestion-img-desc").text("Paste link to product page and press Tab");
});

$('#create-suggestion-product-link').blur(function(){
	if( trim($(this).val() ) != ""){
		url = $(this).val();
			$('#create-suggestion-img').attr('src','/loader.gif');
			$.get('/preview?url='+url, function(response){
				console.log(response);
				if(typeof response.error != 'undefined'){
					$('#create-suggestion-img').attr('src','/x.gif');
					alert(response.error);
				}
				images = response.images;
				currentImageIndex = 0;
				console.log(images);
				var imgSrc = images[currentImageIndex];
				$('#create-suggestion-img').attr("src",imgSrc);
				$('#create-suggestion-img-url').attr("src",imgSrc);
				$("#suggestion-img-nav").show();
				$("#suggestion-img-desc").text("Select product image");
				$("#suggestion-img-count").text("1 of "+images.length);
			});	
	}
	return false;
});

$('#suggestion-img-left').click(function(){
	currentImageIndex = (((currentImageIndex - 1) % images.length) + images.length) % images.length
	var imgSrc = images[currentImageIndex];
	$('#create-suggestion-img').attr("src",imgSrc);
	$('#create-suggestion-img-url').attr("src",imgSrc);
	$("#suggestion-img-count").text((currentImageIndex+1)+" of "+images.length);

});

$('#suggestion-img-right').click(function(){
	currentImageIndex = (((currentImageIndex + 1) % images.length) + images.length) % images.length
	var imgSrc = images[currentImageIndex];
	$('#create-suggestion-img').attr("src",imgSrc);
	$('#create-suggestion-img-url').attr("src",imgSrc);
	$("#suggestion-img-count").text((currentImageIndex+1)+" of "+images.length);

});





});