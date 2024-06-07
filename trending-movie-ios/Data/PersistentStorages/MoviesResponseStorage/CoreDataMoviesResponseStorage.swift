//
//  CoreDataMoviesResponseStorage.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 5/6/24.
//

import Foundation
import CoreData

final class CoreDataMoviesResponseStorage: MoviesResponseStorage {

    private let coreDataStorage: CoreDataStorage

    init(coreDataStorage: CoreDataStorage = CoreDataStorage.shared) {
        self.coreDataStorage = coreDataStorage
    }

    // MARK: - Private

    private func fetchRequest(for requestDto: MoviesRequestable) -> NSFetchRequest<MoviesRequestEntity> {
        let request: NSFetchRequest = MoviesRequestEntity.fetchRequest()
        if let requestDto = requestDto as? MoviesQueryRequestDTO {
            request.predicate = NSPredicate(format: "%K = %@ AND %K = %d",
                                            #keyPath(MoviesRequestEntity.query), requestDto.query,
                                            #keyPath(MoviesRequestEntity.page), requestDto.page)
        } else {
            request.predicate = NSPredicate(format: "%K = %d",
                                            #keyPath(MoviesRequestEntity.page), requestDto.page)
        }
        return request
    }

    private func deleteResponse(for requestDto: MoviesQueryRequestDTO,
                                in context: NSManagedObjectContext) {
        let request = fetchRequest(for: requestDto)
        do {
            if let result = try context.fetch(request).first {
                context.delete(result)
            }
        } catch {
            print(error)
        }
    }

    // MARK: - MoviesResponseStorage
    func getResponse(for request: MoviesRequestable,
                     completion: @escaping (Result<MoviesResponseDTO?, Error>) -> Void) {
        coreDataStorage.performBackgroundTask { context in
            do {
                let fetchRequest = self.fetchRequest(for: request)
                let requestEntity = try context.fetch(fetchRequest).first
                completion(.success(requestEntity?.response?.toDTO()))
            } catch {
                completion(.failure(CoreDataStorageError.readError(error)))
            }
        }
    }

    func getDetailsMovie(for movieId: Int,
                         completion: @escaping DetailsMovieResult) {
        coreDataStorage.performBackgroundTask { context in
            do {
                let fetchRequest: NSFetchRequest<MovieResponseEntity> = MovieResponseEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %d", movieId)
                let existingEntities = try context.fetch(fetchRequest).first
                completion(.success(existingEntities?.toDTO()))
            } catch {
                completion(.failure(CoreDataStorageError.readError(error)))
            }
        }
    }

    func save(response: MoviesResponseDTO) {
        coreDataStorage.performBackgroundTask { context in
            do {
                // Create a fetch request to check for existing items
                let fetchRequest: NSFetchRequest<MoviesResponseEntity> = MoviesResponseEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "%K = %d", #keyPath(MoviesResponseEntity.page), response.page)
                
                let existingEntities = try context.fetch(fetchRequest)
                
                let responseEntity: MoviesResponseEntity
                if let existingEntity = existingEntities.first {
                    responseEntity = existingEntity
                    responseEntity.update(from: response, in: context)
                } else {
                    responseEntity = response.toEntity(in: context)
                }

                try context.save()
            } catch {
                debugPrint("CoreDataMoviesResponseStorage Unresolved error \(error), \((error as NSError).userInfo)")
            }
        }
    }

    func save(response: MovieDetailsResponseDTO) {
        coreDataStorage.performBackgroundTask { context in
            do {
                let fetchRequest: NSFetchRequest<MovieResponseEntity> = MovieResponseEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %d", response.id)
                if let existingEntities = try context.fetch(fetchRequest).first {
                    context.delete(existingEntities)
                }
                let _ = response.toEntity(in: context)
                try context.save()
            } catch {
                debugPrint("CoreDataMoviesResponseStorage Unresolved error \(error), \((error as NSError).userInfo)")
            }
        }
    }

    func save(response responseDto: MoviesResponseDTO,
              for requestDto: MoviesQueryRequestDTO) {
        coreDataStorage.performBackgroundTask { context in
            do {
                self.deleteResponse(for: requestDto, in: context)

                let requestEntity = requestDto.toEntity(in: context)
                requestEntity.response = responseDto.toEntity(in: context)

                try context.save()
            } catch {
                // TODO: - Log to Crashlytics
                debugPrint("CoreDataMoviesResponseStorage Unresolved error \(error), \((error as NSError).userInfo)")
            }
        }
    }
}

extension MoviesResponseEntity {
    func update(from dto: MoviesResponseDTO, in context: NSManagedObjectContext) {
        self.page = Int32(dto.page)
        self.totalPages = Int32(dto.totalPages)

        // Delete existing movies and add new ones to avoid duplicates
        if let existingMovies = self.movies as? Set<MovieResponseEntity> {
            for movie in existingMovies {
                context.delete(movie)
            }
        }
        
        self.movies = NSSet(array: dto.movies.map { $0.toEntity(in: context) })
    }
}
