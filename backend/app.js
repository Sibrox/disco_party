import express from 'express';
import cors from 'cors';
import fs from 'fs';
import querystring from 'querystring';
import request from 'request';
import dotenv from 'dotenv';

import { SpotifyApi } from './spotify/spotifyapi.js';

dotenv.config();

const client_id = process.env.SPOTIFY_CLIENT_ID;
const client_secret = process.env.SPOTIFY_CLIENT_SECRET;
const redirect_uri = process.env.SPOTIFY_REDIRECT_URI || 'http://localhost:8080/callback';
const port = process.env.PORT || 8080;

if (!client_id || !client_secret) {
  console.error('Error: Missing required environment variables. Please check your .env file.');
  console.error('Required variables: SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET');
  process.exit(1);
}

var app = express();
app.use(cors());

app.get('/login', function(req, res) {
  var state = "state";
  var scope = 'user-read-private user-read-playback-state user-modify-playback-state user-read-currently-playing user-read-email';

  res.redirect('https://accounts.spotify.com/authorize?' +
    querystring.stringify({
      response_type: 'code',
      client_id: client_id,
      client_secret: client_secret,
      scope: scope,
      redirect_uri: redirect_uri,
      state: state
    }));
});

app.get('/save_token', function(req, res) {

  var token = req.query.access_token;
  var refresh = req.query.refresh_token;
  fs.writeFileSync('token.txt', token, function(err) {
    if (err) {
      return console.log(err);
    }
    console.log('Access Token saved to token.txt');
  });
  fs.writeFileSync('refresh.txt', refresh, function(err) {
    if (err) {
      return console.log(err);
    }
    console.log('Refresh Token saved to refresh.txt');
  });
  
  return res.json("Login successful. You can class the window");
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

  const api = new SpotifyApi(client_id, client_secret);
  api.executeWithTokenRefresh(async () => {
    return await api.currentPlayback();
  }).then((song) => {
    if(song === null) {
      return res.status(404).send("No song is currently playing");
    }
    return res.json(JSON.parse(song.toJsonString()));
  }).catch((error) => {
    return res.status(500).send(error.message);
  });
});

app.get('/search', async function(req, res) {
  const api = new SpotifyApi(client_id, client_secret
  );
  api.executeWithTokenRefresh(async () => {
    return await api.searchSong(req.query.q);
  }).then((songs) => {
    return res.json(songs);
  }).catch((error) => {
    return res.status(500).send(error.message);
  });
});

app.get('/add_to_queue', async function(req, res) {
  var uri = req.query.uri || null;

  if (uri === null) {
    return res.status(400).send("Missing URI");
  }

  await new SpotifyApi().addSongToQueue(uri);
    
  return res.send("OK");
});


app.listen(port, () => {
  console.log(`Server listening on port ${port}`);  
});