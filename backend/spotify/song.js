export class Song {
    constructor(name, artist, album, duration_ms, progress_ms, uri, image) {
        this.name = name;
        this.artist = artist;
        this.album = album;
        this.duration_ms = duration_ms;
        this.progress_ms = progress_ms;
        this.uri = uri;
        this.image = image
    }

    static fromJSON(json) {
        return new Song(json.name, json.album.artists[0].name, json.album.name, json.duration_ms, json.progress_ms, json.uri, json.album.images[0].url);
    }

    toJsonString() {
        return JSON.stringify({
            name: this.name,
            artist: this.artist,
            album: this.album,
            duration_ms: this.duration_ms,
            progress_ms: this.progress_ms,
            uri: this.uri,
            image: this.image
        });
    }
}