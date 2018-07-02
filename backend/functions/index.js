'use strict';

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');
var smtpTransport = require('nodemailer-smtp-transport');
// Configure the email transport using the default SMTP transport and a GMail account.
// For other types of transports such as Sendgrid see https://nodemailer.com/transports/
// TODO: Configure the `gmail.email` and `gmail.password` Google Cloud environment variables.
const gmailEmail = 'zigantic.a@gmail.com';
const gmailPassword = 'zigantic10?';

admin.initializeApp(functions.config().firebase);

var mailTransport = nodemailer.createTransport(smtpTransport({
  service: 'gmail',
  host: 'smtp.gmail.com',
  auth: {
    user: gmailEmail,
    pass: gmailPassword
  }
}));

// email a new survey to the admin
exports.sendEmailConfirmation = functions.database.ref('/surveys/{surveyId}').onWrite((event) => {
  const snapshot = event.data;
  const survey = snapshot.val();

  if (!snapshot.changed('subscribedToMailingList')) {
    return null;
  }

  const mailOptions = {
    from: '"Zigantic" <noreply@firebase.com>',
    to: 'zigantic.a@gmail.com',
  };

  //db handle
  var db = admin.database();
        
  //users
  var userRef = db.ref("/users").child(survey.userId);
  var gameRef = db.ref("/products").child(survey.gameId);

   //read username
  userRef.once("value", function(snapshot) {
    var user = snapshot.val();
    //read game
    gameRef.once("value", function(snapshot) {
      var game = snapshot.val();
      mailOptions.subject = user.username + ' surveyed about ' + game.title;
      mailOptions.text = 'Dear Zigantic team.\n' + user.username + '\'s survey is \n\n'
      var questions = survey.questions;
      console.log('survey item ', questions);

      for (var item in questions) {
        console.log('item ', item);
        var itemContent = 'Question : ' + item + '\n'
                          + 'Answer : ' + questions[item] + '\n';
        mailOptions.text = mailOptions.text + itemContent;
      }
      mailOptions.text = mailOptions.text + 'Best Regards.'
      console.log("mail body: " + mailOptions.text);

      return mailTransport.sendMail(mailOptions)
      .then(() => console.log(`Email is successfully sent`))
      .catch((error) => console.error('There was an error while sending the email:', error));  

    }, function (errorObject) {
      console.log("The read game failed: " + errorObject.code);
      return 0;
    });  
  }, function (errorObject) {
    console.log("The read user failed: " + errorObject.code);
    return 0;
  });
});
