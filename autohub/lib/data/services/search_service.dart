import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/models/event_model.dart';
import '../../data/models/post_model.dart';
import '../../providers/app_providers.dart';

class SearchService {
  static List<UserModel> searchUsers(List<UserModel> users, String query) {
    if (query.isEmpty) return users;

    final lowercaseQuery = query.toLowerCase();
    return users.where((user) {
      return user.username.toLowerCase().contains(lowercaseQuery) ||
          user.email.toLowerCase().contains(lowercaseQuery) ||
          user.cars.any(
            (car) =>
                car.make.toLowerCase().contains(lowercaseQuery) ||
                car.model.toLowerCase().contains(lowercaseQuery),
          );
    }).toList();
  }

  static List<EventModel> searchEvents(List<EventModel> events, String query) {
    if (query.isEmpty) return events;

    final lowercaseQuery = query.toLowerCase();
    return events.where((event) {
      return event.eventName.toLowerCase().contains(lowercaseQuery) ||
          event.description.toLowerCase().contains(lowercaseQuery) ||
          event.location.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  static List<PostModel> searchPosts(List<PostModel> posts, String query) {
    if (query.isEmpty) return posts;

    final lowercaseQuery = query.toLowerCase();
    return posts.where((post) {
      return post.content.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  static List<CarModel> searchCars(List<CarModel> cars, String query) {
    if (query.isEmpty) return cars;

    final lowercaseQuery = query.toLowerCase();
    return cars.where((car) {
      return car.make.toLowerCase().contains(lowercaseQuery) ||
          car.model.toLowerCase().contains(lowercaseQuery) ||
          car.color?.toLowerCase().contains(lowercaseQuery) == true ||
          car.modifications.any(
            (mod) => mod.toLowerCase().contains(lowercaseQuery),
          );
    }).toList();
  }
}

class SearchFilters {
  final String? make;
  final String? model;
  final int? minYear;
  final int? maxYear;
  final String? color;
  final String? location;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? upcomingEventsOnly;

  const SearchFilters({
    this.make,
    this.model,
    this.minYear,
    this.maxYear,
    this.color,
    this.location,
    this.startDate,
    this.endDate,
    this.upcomingEventsOnly,
  });

  SearchFilters copyWith({
    String? make,
    String? model,
    int? minYear,
    int? maxYear,
    String? color,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    bool? upcomingEventsOnly,
  }) {
    return SearchFilters(
      make: make ?? this.make,
      model: model ?? this.model,
      minYear: minYear ?? this.minYear,
      maxYear: maxYear ?? this.maxYear,
      color: color ?? this.color,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      upcomingEventsOnly: upcomingEventsOnly ?? this.upcomingEventsOnly,
    );
  }

  bool get hasFilters {
    return make != null ||
        model != null ||
        minYear != null ||
        maxYear != null ||
        color != null ||
        location != null ||
        startDate != null ||
        endDate != null ||
        upcomingEventsOnly != null;
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(const SearchState());

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setSearchType(SearchType type) {
    state = state.copyWith(searchType: type);
  }

  void setFilters(SearchFilters filters) {
    state = state.copyWith(filters: filters);
  }

  void clearFilters() {
    state = state.copyWith(filters: const SearchFilters());
  }

  void clearSearch() {
    state = const SearchState();
  }
}

class SearchState {
  final String query;
  final SearchType searchType;
  final SearchFilters filters;
  final bool isLoading;

  const SearchState({
    this.query = '',
    this.searchType = SearchType.all,
    this.filters = const SearchFilters(),
    this.isLoading = false,
  });

  SearchState copyWith({
    String? query,
    SearchType? searchType,
    SearchFilters? filters,
    bool? isLoading,
  }) {
    return SearchState(
      query: query ?? this.query,
      searchType: searchType ?? this.searchType,
      filters: filters ?? this.filters,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get hasQuery => query.isNotEmpty;
  bool get hasActiveFilters => filters.hasFilters;
}

enum SearchType { all, users, events, posts, cars }

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((
  ref,
) {
  return SearchNotifier();
});

// Filtered data providers
final filteredUsersProvider = Provider<List<UserModel>>((ref) {
  final searchState = ref.watch(searchProvider);
  final allUsers = ref.watch(leaderboardProvider);

  return allUsers.when(
    data: (users) {
      var filteredUsers = SearchService.searchUsers(users, searchState.query);

      // Apply filters
      if (searchState.filters.hasFilters) {
        filteredUsers = filteredUsers.where((user) {
          return user.cars.any(
            (car) => _carMatchesFilters(car, searchState.filters),
          );
        }).toList();
      }

      return filteredUsers;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

final filteredEventsProvider = Provider<List<EventModel>>((ref) {
  final searchState = ref.watch(searchProvider);
  final allEvents = ref.watch(eventsProvider);

  return allEvents.when(
    data: (events) {
      var filteredEvents = SearchService.searchEvents(
        events,
        searchState.query,
      );

      // Apply filters
      if (searchState.filters.hasFilters) {
        filteredEvents = filteredEvents.where((event) {
          return _eventMatchesFilters(event, searchState.filters);
        }).toList();
      }

      return filteredEvents;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

final filteredPostsProvider = Provider<List<PostModel>>((ref) {
  final searchState = ref.watch(searchProvider);
  final allPosts = ref.watch(postsProvider);

  return allPosts.when(
    data: (posts) {
      return SearchService.searchPosts(posts, searchState.query);
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

bool _carMatchesFilters(CarModel car, SearchFilters filters) {
  if (filters.make != null &&
      !car.make.toLowerCase().contains(filters.make!.toLowerCase())) {
    return false;
  }
  if (filters.model != null &&
      !car.model.toLowerCase().contains(filters.model!.toLowerCase())) {
    return false;
  }
  if (filters.minYear != null && car.year < filters.minYear!) {
    return false;
  }
  if (filters.maxYear != null && car.year > filters.maxYear!) {
    return false;
  }
  if (filters.color != null &&
      car.color?.toLowerCase() != filters.color!.toLowerCase()) {
    return false;
  }
  return true;
}

bool _eventMatchesFilters(EventModel event, SearchFilters filters) {
  if (filters.location != null &&
      !event.location.toLowerCase().contains(filters.location!.toLowerCase())) {
    return false;
  }
  if (filters.startDate != null &&
      event.eventDate.isBefore(filters.startDate!)) {
    return false;
  }
  if (filters.endDate != null && event.eventDate.isAfter(filters.endDate!)) {
    return false;
  }
  if (filters.upcomingEventsOnly == true && !event.isUpcoming) {
    return false;
  }
  return true;
}
