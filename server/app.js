var express = require('express')
var AWS = require('aws-sdk')
var uuid = require('uuid')

AWS.config.update({
  region: 'us-west-2',
  accessKeyId: 'AKIAxxxxxxxxxx',
  secretAccessKey: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
});

var S3 = new AWS.S3();

var bucket = 'bugsee-example';

var app = express()
app.post('/users/:userId/objects', function (req, res) {
  console.log('Generating presigned URL for ' + req.params.userId);

  // Generate unique key for the new object
  var key = uuid.v4();

  // Record metadata in the DB, associate it with the user

  // Construct a path where data will be stored in that bucket
  var path = 'upload/' + key;

  // Construct a request
  var request = {
    Bucket: bucket,
    Key: path,
    Expires: 3600 // Valid for only 1 hour

  };

  // Ask
  S3.getSignedUrl('putObject', request, function(err, result) {
    res.send({
        url: result,
        method: 'PUT'
    });
  });
})

app.listen(3000, function () {
  console.log('Example app listening on port 3000!')
})
