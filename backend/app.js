import express from 'express';
import fs from 'fs';
import querystring from 'querystring';
import request from 'request';

import { SpotifyApi } from './spotify/spotifyapi.js';

var client_id = '9f5a185ec2ae478c8b24a54ee685680c';
var client_secret = '01c3fd8034d64eb6bcc3aae7e1588620';
var redirect_uri = 'http://localhost:8080/callback';

var app = express();

app.get('/login', function(req, res) {

  var state = "state";
  var scope = 'user-read-private user-read-playback-state user-modify-playback-state user-read-currently-playing user-read-email';

  res.redirect('https://accounts.spotify.com/authorize?' +
    querystring.stringify({
      response_type: 'code',
      client_id: client_id,
      client_secret,
      scope: scope,
      redirect_uri: redirect_uri,
      state: state
    }));
});

app.get('/dashboard', function(req, res) {
  res.send('Dashboard');
});

app.get('/save_token', function(req, res) {

  var token = req.query.access_token;
  var refresh = req.query.refresh_token;
  console.log(token);
  fs.writeFile('token.txt', token, function(err) {
    if (err) {
      return console.log(err);
    }
    console.log('Access Token saved to token.txt');
  });
  fs.writeFile('refresh.txt', refresh, function(err) {
    if (err) {
      return console.log(err);
    }
    console.log('Refresh Token saved to refresh.txt');
  });
  res.redirect('/player');
});

app.get('/callback', function(req, res)  {

  var code = req.query.code || null;
  var state = req.query.state || null;

  if (state === null) {
    res.redirect('/#' +
      querystring.stringify({
        error: 'state_mismatch'
      }));
  } else {
    var authOptions = {
      url: 'https://accounts.spotify.com/api/token',
      form: {
        code: code,
        redirect_uri: redirect_uri,
        grant_type: 'authorization_code'
      },
      headers: {
        'content-type': 'application/x-www-form-urlencoded',
        'Authorization': 'Basic ' + (new Buffer.from(client_id + ':' + client_secret).toString('base64'))
      },
      json: true
    };

    request
    .post(authOptions,function(error, response, body) {
      console.log(body.access_token);
      console.log(response.statusCode);

      var access_token = body.access_token;
      var refresh_token = body.refresh_token;

      res.redirect('/save_token?' +
        querystring.stringify({
          access_token: access_token,
          refresh_token: refresh_token
        }));
    });

  }
});

app.get('/player', async function(req, res) {

  var song = await new SpotifyApi().currentPlayback()

  return res.json(JSON.parse(song.toJsonString()));
});

app.get('/search', async function(req, res) {

  var query = req.query.q;

  var songs = await new SpotifyApi().searchSong(query);

  return res.json(songs.map(song => JSON.parse(song.toJsonString())));
});

app.get('/add_to_queue', async function(req, res) {
  var uri = req.query.uri || null;

  if (uri === null) {
    return res.status(400).send("Missing URI");
  }

  await new SpotifyApi().addSongToQueue(uri);

  return res.send("OK");
});

const port = 8080;

app.listen(port, () => {
  console.log(`Server listening on port ${port}`);  
});