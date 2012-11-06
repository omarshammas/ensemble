$(document).ready(function()
{
// Logging - Disable in production
Pusher.log = function() { if (window.console) window.console.log.apply(window.console, arguments); };


// Global variable "channel" is set in the view
var pusher = new Pusher('9ceb5ef670c4262bfbca');
Pusher.channel_auth_endpoint = '/api/authenticate';
var ensembleChannel = pusher.subscribe('ensemble-1');



// Deal with incoming messages!
ensembleChannel.bind('post_comment', function(comment) {
  var comment_class = 'alert alert-info';
  if(comment.user_id == comment.task.user_id)
      comment_class = 'alert alert-error';
  else if(comment.user_id == comment.user.id)
      comment_class = 'alert alert-success'; 
  
  $('#chat-messages-list').append('<li class="message"><div class ="'+ comment_class +'"><p><strong> User' + comment.user_id + '</strong>: ' + replaceURLWithHTMLLinks(comment.body) + '</p></div></li>');
  scrollToTheTop();
});
ensembleChannel.bind('post_suggestion', function(suggestion) {
  var list_item = '<li class="suggestion"><button class="btn btn-mini"><i class="icon-thumbs-up"><input type="hidden" value="';
  list_item += suggestion.id;
  list_item += '" href="#"/></i></button> ';
  list_item += replaceURLWithHTMLLinks(suggestion.body);
  list_item += '<span class="badge badge-success">';
  list_item += suggestion.vote_count;
  list_item += '</span></li>';
  $('#suggestion-list').append(list_item);
  scrollToTheTop();
});

ensembleChannel.bind('post_up_vote', function(suggestions) {
  $('.suggestion').remove();
  var ii;
  var list_item;
  for (ii = 0; ii < suggestions.length; ++ii) {
      suggestion = suggestions[ii];
      list_item = '<li class="suggestion"><button class="btn btn-mini"><i class="icon-thumbs-up"><input type="hidden" value="';
      list_item += suggestion.id;
      list_item += '" href="#"/></i></button> ';
      list_item += replaceURLWithHTMLLinks(suggestion.body);
      list_item += '<span class="badge badge-success">';
      list_item += suggestion.vote_count;
      list_item += '</span></li>';
      $('#suggestion-list').append(list_item);    
  }
});

$('.btn.btn-mini').live("click",function(){
    var suggestion_id = $(this).children().find('input[type="hidden"]');
    post_up_vote(suggestion_id.val());
});

$('#comment-btn').click(function(){
    post_comment();
});

$('#suggest-btn').click(function(){
    post_suggestion();
});


});