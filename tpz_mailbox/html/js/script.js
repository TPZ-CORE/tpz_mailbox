

function CloseMailBox() {

  $("#mailbox").fadeOut();
	$("#notification_message").fadeOut();
	$("#telegrams").fadeOut();
	//$("#contacts").fadeOut();
  $("#create").fadeOut();
  $("#review").fadeOut();

	$("#telegrams-list").html('');
	//$("#contacts-list").html('');
  $("#telegrams-pages-list").html(''); 

  
  $("#telegrams-create-recipient-input").val('');
  $("#telegrams-create-title-input").val('');
  $("#telegrams-create-message-textarea").val('');

	$.post('http://tpz_mailbox/close', JSON.stringify({}));
}

$(function() {

	window.addEventListener('message', function(event) {
		
    var item = event.data;

		if (item.type == "enable") {
			document.body.style.display = item.enable ? "block" : "none";

      $("#mailbox").fadeIn(1000);
      $("#telegrams").fadeIn(1000);

      $("#telegrams-list-button").css('color', "#69725edc");
      //$("#contacts-list-button").css('color', 'rgb(34, 34, 34)');

    } else if (event.data.action == "loadTelegrams") {
      var prod_letter = event.data.telegram;
      var backgroundImage = "closed_mail";

      if (Number(prod_letter.viewed) === 1) {
        backgroundImage = "opened_mail";
      }

      var title    = prod_letter.title.slice(0, 14);
      var username = prod_letter.sender_username.slice(0, 14);

      var city     = prod_letter.city.slice(0, 3);
      city         = city.toUpperCase();

      $("#telegrams-list").append(
				`<div id="telegrams-list-main" ></div>` +
        `<div id="telegrams-list-view-image" style = "background-image: url('img/icons/` + backgroundImage + `.png'); "> </div>` +
				`<div telegramId = "` +  prod_letter.id 
        + `" senderUsername = "` + prod_letter.sender_username 
        + `" senderUniqueId = "` + prod_letter.sender_uniqueId 
        + `" date = "` + prod_letter.timestamp
        + `" title = "` + prod_letter.title
        + `" message = "` + prod_letter.message

        + `" id="telegrams-list-title" >` + title + ` </div>` +
				`<div id="telegrams-list-sender-username" >` + ' ‍ ‍' + username + `</div>` +
				`<div id="telegrams-list-sender-city" >` + city + `</div>` +
        `<div id="telegrams-list-sender-uniqueid" >` + prod_letter.sender_uniqueId + ` ‍ ‍</div>` +
        `<div id="telegrams-list-timestamp">` + prod_letter.timestamp + `</div>`
			);

    } else if (event.data.action == 'setTotalPages') {
      let pages    = event.data.total;
      let selected = event.data.selected;

      if (pages > 1 ) {

        $.each([ 1, pages ], function( index, value ) {
          var opacity = selected == value ? '0.7' : null;
          $("#telegrams-pages-list").append(`<div page = "` + value + `" id="telegrams-pages-list-value" style = "opacity: ` + opacity + `;" >` + value + `</div>`);
        });

      }else{
        $("#telegrams-pages-list").append(`<div page = "1" id="telegrams-pages-list-value" style = "opacity: 0.7;" >1</div>`);
      }


    } else if (event.data.action == "resetTelegrams") {
      $("#telegrams-list").html('');
      $("#telegrams-pages-list").html(''); 

    } else if (event.data.action == "onSuccessfullTelegramSent") {

      $("#telegrams-create-recipient-input").val('');
      $("#telegrams-create-title-input").val('');
      $("#telegrams-create-message-textarea").val("");

      $("#create").fadeOut(); // Closing Telegram Create NUI

      $("#telegrams").fadeIn();
      $("#telegrams-list-button").css('color', "#69725edc");

      sendNotification(Locales.TELEGRAM_SENT, Config.NotificationColors['success']);

    } else if (event.data.action == "loadInformation"){

      $("#current-mailbox-city-title").fadeIn();
      $("#user-uniqueid-title").fadeIn();

      $("#current-mailbox-city-title").text(event.data.location);
      $("#user-uniqueid-title").text(event.data.uniqueId);

    } else if (event.data.action == "sendNotification") {
      var prod_notify = event.data.notification_data;
      sendNotification(prod_notify.message, prod_notify.color);

    } else if (event.data.action == "close") {
      CloseMailBox();
    }

  });


  /*  ----------------------------------------------------------------------
                         Main Telegram Page (Telegrams)                     
      ---------------------------------------------------------------------- */

  // This event is changing the pages properly to get the telegrams based on the selected page.
  $("#mailbox").on("click", "#telegrams-pages-list-value", function() {
    playAudio("button_click.wav");

    var $button = $(this);
    var $selectedPage = $button.attr('page');

    $.post("http://tpz_mailbox/selectPage", JSON.stringify({ value: $selectedPage }));
  });

  // This event is opening the selected button (Telegrams)
  $("#mailbox").on("click", "#telegrams-list-button", function() {
    playAudio("button_click.wav");

    $("#current-mailbox-city-title").fadeIn();
    $("#user-uniqueid-title").fadeIn();

    $("#create").fadeOut(); // Closing Telegram Create NUI
    $("#review").fadeOut(); // Closing Review NUI
    //$("#contacts").fadeOut(); // Closing Contacts NUI

    $("#telegrams").fadeIn();
    $("#telegrams-list-button").css('color', "#69725edc");
    //$("#contacts-list-button").css('color', 'rgb(34, 34, 34)');

    $.post("http://tpz_mailbox/refresh", JSON.stringify({}));

  });

  // This event is opening another NUI for sending a telegram.
  $("#mailbox").on("click", "#telegrams-list-create-telegram-button", function() {
    playAudio("button_click.wav");

    $("#telegrams").fadeOut(); // Closing telegrams (Main Page)
    $("#telegrams-list-button").css('color', 'rgb(34, 34, 34)');

    
    $("#create").fadeIn(); // Opening Telegram Create NUI
  });

  // This event is sending a telegram if has the required parameters and telegram ID is valid.
  $("#mailbox").on("click", "#telegrams-create-send-button", function() {
    
    let $telegramId = $("#telegrams-create-recipient-input").val();

    if ($telegramId == null || $telegramId.length === 0) {
      sendNotification(Locales.INVALID_RECIPIENT_ID, Config.NotificationColors['error']);
      return;
    }

    let $title = $("#telegrams-create-title-input").val();

    if ($title == null || $title.length === 0) {
      sendNotification(Locales.INVALID_TITLE, Config.NotificationColors['error']);
      return;
    }

    var message = document.getElementById("telegrams-create-message-textarea").value;
		let $message = message.replace(/\n/g, "\r\n"); // To retain the Line breaks.

    $.post("http://tpz_mailbox/sendTelegram", JSON.stringify({
      telegramId : $telegramId,
      title : $title,
      content : $message
    }));

  });


  // This event is triggered on the telegrams list for reading a telegram.
  // It has a delete and reply buttons as extra options.
  $("#mailbox").on("click", "#telegrams-list-title", function() {
    playAudio("button_click.wav");

    $("#telegrams").fadeOut(); // Closing telegrams (Main Page)
    $("#telegrams-list-button").css('color', 'rgb(34, 34, 34)');

    var $button         = $(this);
    var $id             = $button.attr('telegramId');
    var $senderUsername = $button.attr('senderUsername');
    var $senderUniqueId = $button.attr('senderUniqueId');
    var $date           = $button.attr('date');
    var $title          = $button.attr('title');
    var $message        = $button.attr('message');


    $("#telegrams-review-sender-text").text($senderUsername);
    $("#telegrams-review-recipient-text").text($senderUniqueId);

    $("#telegrams-review-date-text").text($date);
    $("#telegrams-review-message-title-text").text($title);
    $("#telegrams-review-message-textarea").val($message);
    $("#telegrams-review-signature-text").text($senderUsername);

    $("#current-mailbox-city-title").fadeOut();
    $("#user-uniqueid-title").fadeOut();

    $("#review").fadeIn(); // Opening Review NUI

    SelectedMailIndex = $id;
    SelectedMailRecipientId = $senderUniqueId;

    $.post("http://tpz_mailbox/setMailViewedById", JSON.stringify({telegramId: $id}));
  });

  // This event is triggered for deleting the selected telegram.
  $("#mailbox").on("click", "#telegrams-review-delete-button", function() {
    playAudio("button_click.wav");

    $("#current-mailbox-city-title").fadeIn();
    $("#user-uniqueid-title").fadeIn();

    $("#create").fadeOut(); // Closing Telegram Create NUI
    $("#review").fadeOut(); // Closing Review NUI
    //$("#contacts").fadeOut(); // Closing Contacts NUI

    $("#telegrams").fadeIn();
    $("#telegrams-list-button").css('color', "#69725edc");

    $.post("http://tpz_mailbox/delete", JSON.stringify({telegramId: SelectedMailIndex }));
  });

  $("#mailbox").on("click", "#telegrams-review-reply-button", function() {
    playAudio("button_click.wav");

    $("#current-mailbox-city-title").fadeIn();
    $("#user-uniqueid-title").fadeIn();

    $("#review").fadeOut(); // Closing Review NUI
    $("#telegrams").fadeOut(); // Closing telegrams (Main Page)
    $("#telegrams-list-button").css('color', 'rgb(34, 34, 34)');

    $("#telegrams-create-recipient-input").val(SelectedMailRecipientId);
    
    $("#create").fadeIn(); // Opening Telegram Create NUI

  });

  //<div id="telegrams-review-reply-button"></div>

  /*-----------------------------------------------------------
  General Action
  -----------------------------------------------------------*/

  $("#mailbox").on("click", "#close-button", function() {
    playAudio("button_click.wav");
    CloseMailBox();
  });

  $("body").on("keyup", function (key) { if (key.which == 27){ CloseMailBox(); } });
  
});
