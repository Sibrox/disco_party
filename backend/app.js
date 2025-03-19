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
const port = process.env.PORT || 8080;
const server_ip = process.env.SERVER_IP || 'localhost';
const redirect_uri = process.env.SPOTIFY_REDIRECT_URI || `http://${server_ip}:${port}/callback`;

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

app.get('/callback', function(req, res) {
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
        'Authorization': 'Basic ' + (Buffer.from(client_id + ':' + client_secret).toString('base64'))
      },
      json: true
    };

    request.post(authOptions, function(error, response, body) {
      if (error || response.statusCode !== 200) {
        console.error('Error getting tokens:', error || body);
        return res.status(500).send('Authentication failed');
      }
      
      var access_token = body.access_token;
      var refresh_token = body.refresh_token;

      // Write tokens directly here instead of redirecting
      try {
        // Write the tokens to files
        fs.writeFileSync('token.txt', access_token);
        fs.writeFileSync('refresh.txt', refresh_token);
        
        console.log('Access and refresh tokens saved successfully');
        
        // Respond with success page
        res.send(`
          <!DOCTYPE html>
          <html>
            <head>
              <title>Authentication Successful</title>
              <style>
                body {
                  font-family: Arial, sans-serif;
                  text-align: center;
                  padding: 40px;
                  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
                }
                .container {
                  background-color: white;
                  padding: 30px;
                  border-radius: 10px;
                  box-shadow: 0 4px 15px rgba(0,0,0,0.1);
                  max-width: 600px;
                  margin: 0 auto;
                }
                h1 {
                  color: #1DB954;
                }
                .success-icon {
                  font-size: 60px;
                  margin-bottom: 20px;
                }
                .message {
                  margin: 20px 0;
                  color: #333;
                }
                .close-button {
                  background-color: #1DB954;
                  color: white;
                  border: none;
                  padding: 10px 20px;
                  border-radius: 30px;
                  font-size: 16px;
                  cursor: pointer;
                  transition: background-color 0.3s;
                }
                .close-button:hover {
                  background-color: #1AA34A;
                }
              </style>
            </head>
            <body>
              <div class="container">
                <div class="success-icon">✅</div>
                <h1>Authentication Successful</h1>
                <p class="message">Your Spotify account has been successfully connected.</p>
                <p>You can now close this window and return to the application.</p>
                <button class="close-button" onclick="window.close()">Close Window</button>
              </div>
            </body>
          </html>
        `);
      } catch (err) {
        console.error('Error saving tokens to file:', err);
        res.status(500).send('Error saving authentication tokens');
      }
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