import request from "request";
import fs from "fs";
import { Song } from "./song.js";

export class SpotifyApi {

    constructor() {
        this.client_id = '9f5a185ec2ae478c8b24a54ee685680c';
        this.client_secret = '01c3fd8034d64eb6bcc3aae7e1588620';
        this.access_token = fs.readFileSync('token.txt', 'utf8').toString();;
        this.refresh_token = fs.readFileSync('refresh.txt', 'utf8').toString();;
    }
    
    async refreshAccessToken() {
        console.log("Attempting to refresh access token...");
        
        return new Promise((resolve, reject) => {
          const authOptions = {
            url: 'https://accounts.spotify.com/api/token',
            headers: { 
              'Authorization': 'Basic ' + Buffer.from(this.client_id + ':' + this.client_secret).toString('base64') 
            },
            form: {
              grant_type: 'refresh_token',
              refresh_token: this.refresh_token
            },
            json: true
          };
      
          request.post(authOptions, (error, response, body) => {
            if (error || response.statusCode !== 200) {
              console.error("Failed to refresh token:", error || body);
              return reject(error || new Error('Failed to refresh token'));
            }
      
            const access_token = body.access_token;
            console.log("Token refreshed successfully");
            
            this.access_token = access_token;
            
            try {
              fs.writeFileSync('token.txt', access_token);
              console.log('Access Token saved to token.txt');
              resolve(access_token);
            } catch (err) {
              console.error('Error saving refreshed token to file:', err);
              resolve(access_token);
            }
          });
        });
      }

    async executeWithTokenRefresh(apiCall) {
        try {
            return await apiCall();
        } catch (error) {
            if (error.statusCode === 401) {
            console.log("Received 401 error, trying to refresh token...");
            try {
                await this.refreshAccessToken();   
                return await apiCall();
            } catch (refreshError) {
                throw new Error(`Token refresh failed: ${refreshError.message}`);
            }
            } else {
            throw error;
            }
        }
    }

    async currentPlayback() {
        const apiCall = () => {
          return new Promise((resolve, reject) => {
            request({
              url: 'https://api.spotify.com/v1/me/player',
              headers: {
                'Authorization': 'Bearer ' + this.access_token
              },
              json: true
            }, (error, response, body) => {
              if (error) {
                console.error("Error fetching current playback:", error);
                return resolve(null);
              }
              
              if (response.statusCode === 401) {
                const unauthorizedError = new Error('Unauthorized');
                unauthorizedError.statusCode = 401;
                return reject(unauthorizedError);
              }
              
              if (response.statusCode === 204 || !body) {
                console.log("No active player or no track currently playing");
                return resolve(null);
              }
              
              if (response.statusCode !== 200) {
                console.error("API returned status code:", response.statusCode);
                return resolve(null);
              }
              
              if (!body.item) {
                console.log("Player exists but no track is playing");
                return resolve(null);
              }
              
              try {
                const songJSON = {...body.item, progress_ms: body.progress_ms};
                const song = Song.fromJSON(songJSON);
                resolve(song);
              } catch (err) {
                reject(err);
              }
            });
          });
        };
      
        try {
          return await this.executeWithTokenRefresh(apiCall);
        } catch (err) {
          console.error("Failed after token refresh attempt:", err);
          return null;
        }
      }

      async searchSong(query) {
        const apiCall = () => {
          return new Promise((resolve, reject) => {
            request({
              url: `https://api.spotify.com/v1/search?q=${encodeURIComponent(query)}&type=track&limit=10`,
              headers: {
                'Authorization': 'Bearer ' + this.access_token
              },
              json: true
            }, (error, response, body) => {
              if (error) {
                console.error("Error searching song:", error);
                return resolve([]);
              }
              
              if (response.statusCode === 401) {
                const unauthorizedError = new Error('Unauthorized');
                unauthorizedError.statusCode = 401;
                return reject(unauthorizedError);
              }
              
              if (response.statusCode !== 200) {
                console.error("API returned status code:", response.statusCode);
                return resolve([]);
              }
              
              if (!body || !body.tracks || !body.tracks.items || body.tracks.items.length === 0) {
                console.log("No tracks found");
                return resolve([]);
              }
              
              try {
                resolve(body.tracks.items.map(Song.fromJSON));
              } catch (err) {
                resolve([]);
              }
            });
          });
        };
      
        try {
          return await this.executeWithTokenRefresh(apiCall);
        } catch (err) {
          console.error("Failed after token refresh attempt:", err);
          return [];
        }
      }

    async addSongToQueue(songUri) {
        const apiCall = () => {
            return new Promise((resolve, reject) => {
            request({
                url: `https://api.spotify.com/v1/me/player/queue?uri=${encodeURIComponent(songUri)}`,
                method: 'POST',
                headers: {
                'Authorization': 'Bearer ' + this.access_token
                },
                json: true,
            }, (error, response, body) => {
                if (error) {
                console.error("Error adding song to queue:", error);
                return reject(error);
                }
                
                if (response.statusCode === 401) {
                const unauthorizedError = new Error('Unauthorized');
                unauthorizedError.statusCode = 401;
                return reject(unauthorizedError);
                }
                
                if (response.statusCode === 404) {
                return reject(new Error('No active device found'));
                }
                
                if (response.statusCode !== 200) {
                return reject(new Error(`HTTP error! Status: ${response.statusCode}`));
                }
                
                resolve(true);
            });
            });
        };
        
        try {
            return await this.executeWithTokenRefresh(apiCall);
        } catch (err) {
            console.error("Failed after token refresh attempt:", err);
            return false; // Return false to indicate failure after refresh attempt
        }
    }
}