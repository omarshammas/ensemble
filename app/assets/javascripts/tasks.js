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
  $('#chat-messages-list').append('<li class="message"><strong> User' + comment.user_id + '</strong>: ' + replaceURLWithHTMLLinks(comment.body) + '</li>');
  scrollToTheTop();
});
ensembleChannel.bind('post_suggestion', function(suggestion) {
  $('#suggestion-list').append('<li class="suggestion"><a href="#"><i class="icon-thumbs-up"></i></a> <a href="#"><i class="icon-thumbs-down"></i></a>' + replaceURLWithHTMLLinks(suggestion.body) + '</li>');
  scrollToTheTop();
});

$('#comment-btn').click(function(){
    post_comment();
});

$('#suggest-btn').click(function(){
    post_suggestion();
});


});