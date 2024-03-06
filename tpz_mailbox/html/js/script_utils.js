let SelectedMailIndex = 0;
let SelectedMailRecipientId = null;

const loadScript = (FILE_URL, async = true, type = "text/javascript") => {
  return new Promise((resolve, reject) => {
      try {
          const scriptEle = document.createElement("script");
          scriptEle.type = type;
          scriptEle.async = async;
          scriptEle.src =FILE_URL;

          scriptEle.addEventListener("load", (ev) => {
              resolve({ status: true });
          });

          scriptEle.addEventListener("error", (ev) => {
              reject({
                  status: false,
                  message: `Failed to load the script ${FILE_URL}`
              });
          });

          document.body.appendChild(scriptEle);
      } catch (error) {
          reject(error);
      }
  });
};

loadScript("js/locales/locales-" + Config.Locale + ".js").then( data  => { 
	
	$("#mailbox").fadeOut();

	displayPage("notification", "visible");
	$("#notification_message").fadeOut();
  
	displayPage("mailbox-telegrams", "visible");
	$("#telegrams").fadeOut();
  
	//displayPage("mailbox-contacts", "visible");
	//$("#contacts").fadeOut();

	displayPage("mailbox-create", "visible");
	$("#create").fadeOut();

	displayPage("mailbox-review", "visible");
	$("#review").fadeOut();

	$("#telegrams-list-button").text(Locales.TELEGRAMS_BUTTON);
	//$("#contacts-list-button").text(Locales.CONTACTS_BUTTON);

	$("#telegrams-sender-title").text(Locales.TELEGRAMS_SENDER_TITLE);
	$("#telegrams-sender-sender-title").text(Locales.TELEGRAMS_SENDER);
	$("#telegrams-sender-timestamp-title").text(Locales.TELEGRAMS_SENDER_TIMESTAMP);

	$("#telegrams-list-create-telegram-button").text(Locales.TELEGRAMS_SEND_TELEGRAM);

	$("#telegrams-create-title").text(Locales.TELEGRAMS_CREATE_TITLE);
	$("#telegrams-create-message-title").text(Locales.TELEGRAMS_CREATE_MESSAGE);
	$("#telegrams-create-recipient-title").text(Locales.TELEGRAMS_CREATE_RECIPIENT);

	$("#telegrams-create-send-button").text(Locales.TELEGRAMS_CREATE_SEND_TELEGRAM);

	/* Review */

	$("#telegrams-review-title").text(Locales.TELEGRAMS_CREATE_TITLE);
	$("#telegrams-review-message-title").text(Locales.TELEGRAMS_CREATE_MESSAGE);
	$("#telegrams-review-sender-title").text(Locales.TELEGRAMS_REVIEW_SENDER);
	$("#telegrams-review-recipient-title").text(Locales.TELEGRAMS_REVIEW_RECIPIENT);
	$("#telegrams-review-date-title").text(Locales.TELEGRAMS_REVIEW_DATE);

	$("#telegrams-review-signature-title").text(Locales.TELEGRAMS_REVIEW_SIGNATURE);
	$("#telegrams-review-delete-button").text(Locales.TELEGRAMS_REVIEW_DELETE_BUTTON);
	$("#telegrams-review-reply-button").text(Locales.TELEGRAMS_REVIEW_REPLY_BUTTON);

}) .catch( err => { console.error(err); });


function playAudio(sound) {
	let audio = new Audio('./audio/' + sound);
	audio.volume = Config.DefaultClickSoundVolume;
	audio.play();
}

function load(src) {
  return new Promise((resolve, reject) => {
      const image = new Image();
      image.addEventListener('load', resolve);
      image.addEventListener('error', reject);
      image.src = src;
  });
}

function randomIntFromInterval(min, max) { // min and max included 
  return Math.floor(Math.random() * (max - min + 1) + min)
}

function displayPage(page, cb){
  document.getElementsByClassName(page)[0].style.visibility = cb;

  [].forEach.call(document.querySelectorAll('.' + page), function (el) {
    el.style.visibility = cb;
  });
}

function sendNotification(text, color, cooldown){

	cooldown = cooldown == cooldown == null || cooldown == 0 || cooldown === undefined ? 4000 : cooldown;
  
	$("#notification_message").text(text);
	$("#notification_message").css("color", color);
	$("#notification_message").fadeIn();
  
	setTimeout(function() { $("#notification_message").text(""); $("#notification_message").fadeOut(); }, cooldown);
  }
  