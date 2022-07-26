//
//  ViewModel.AppleMusic.swift
//  SharedAux
//
//  Created by Neel Ismail on 2022-07-23.
//

import Foundation
import MusicKit

/*
    This extension handles interactions with the Apple Music APIs
*/
extension ViewModel {
    
    func requestAppleMusicAuthorization() async {
        Task.detached {
            let authorizationStatus = await MusicAuthorization.request()
            if authorizationStatus == .authorized {
                await MainActor.run {
                    self.applicationState = .readyForQueue
                }
            } else {
                await MainActor.run {
                    self.applicationState = .unauthorized
                }
            }
        }
    }
    
    func searchAppleMusicCatalog(for query: String) async {
        do {
            if !query.isEmpty {
                var searchRequest = MusicCatalogSearchRequest(term: query,
                                                              types: [Song.self,
                                                                      Album.self,
                                                                      Artist.self])
                searchRequest.limit = 3
                
                let response = try await searchRequest.response()
                
                let songResults = response.songs.compactMap { $0 }
                let albumResults = response.albums.compactMap { $0 }
                let artistResults = response.artists.compactMap { $0 }
                
                await MainActor.run {
                    searchResults = SearchResults(songs: songResults,
                                                  albums: albumResults,
                                                  artists: artistResults)
                }
            }
        } catch {
            print("Music Catalog Search error: \(error)")
        }
    }
    
    func getArtistInformation(_ artist: Artist) async throws -> Artist {
        do {
            let detailedArtist = try await artist.with([.topSongs, .albums])
            return detailedArtist
        } catch {
            print("An error occurred while retrieving the artist's information: \(error)")
            throw error
        }
    }
    
    func getAlbumInformation(_ album: Album) async throws -> Album {
        do {
            let detailedAlbum = try await album.with([.tracks])
            return detailedAlbum
        } catch {
            print("An error occurred while retrieving the album's information: \(error)")
            throw error
        }
    }
}
