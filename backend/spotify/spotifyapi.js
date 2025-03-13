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

    async currentPlayback() {
        return await new Promise((resolve, reject) => {
            request({
                url: 'https://api.spotify.com/v1/me/player',
                headers: {
                    'Authorization': 'Bearer ' + this.access_token
                },
                json: true
            }, (error, response, body) => {
                if (error) {
                    console.error("Error fetching current playback:", error);
                    return reject(error);
                }
                
                if (response.statusCode !== 200) {
                    console.error("API returned status code:", response.statusCode);
                    return reject(new Error(`HTTP error! Status: ${response.statusCode}`));
                }
                
                if (!body || !body.item) {
                    console.log("No track currently playing");
                    return resolve(null);
                }
                
                try {
                    const songJSON = {...body.item, progress_ms: body.progress_ms};
                    const song = Song.fromJSON(songJSON);
                    console.log(song.toJsonString());
                    resolve(song);
                } catch (err) {
                    reject(err);
                }
            });
        });
    }

    async searchSong(query) {
        return await new Promise((resolve, reject) => {
            request({
                url: `https://api.spotify.com/v1/search?q=${query}&type=track`,
                headers: {
                    'Authorization': 'Bearer ' + this.access_token
                },
                json: true
            }, (error, response, body) => {
                if (error) {
                    console.error("Error searching song:", error);
                    return reject(error);
                }
                
                if (response.statusCode !== 200) {
                    console.error("API returned status code:", response.statusCode);
                    return reject(new Error(`HTTP error! Status: ${response.statusCode}`));
                }
                
                if (!body || !body.tracks || !body.tracks.items || body.tracks.items.length === 0) {
                    console.log("No tracks found");
                    return resolve(null);
                }
                
                try {
                    resolve(body.tracks.items.map(Song.fromJSON));
                } catch (err) {
                    reject(err);
                }
            });
        });
    }


    async addSongToQueue(songUri) {
        return await new Promise((resolve, reject) => {
            request({
                url: `https://api.spotify.com/v1/me/player/queue?uri=${songUri}`,
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
                
                resolve();
            });
        });
    }

    async getSong(id) {
        return await new Promise((resolve, reject) => {
            request({
                method: 'GET',
                url: `https://api.spotify.com/v1/tracks/${id}`,
                headers: {
                    'Authorization': 'Bearer ' + this.access_token
                },
                json: true
            }, (error, response, body) => {
                if (error) {
                    console.error("Error fetching song:", error);
                    return reject(error);
                }
                
                if (response.statusCode !== 200) {
                    console.error("API returned status code:", response.statusCode);
                    return reject(new Error(`HTTP error! Status: ${response.statusCode}`));
                }
                
                try {
                    resolve(Song.fromJSON(body));
                } catch (err) {
                    reject(err);
                }
            });
        });
    }
}