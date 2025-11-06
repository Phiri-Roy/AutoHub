import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/app_providers.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CarComparisonNotifier extends StateNotifier<List<CarModel>> {
  CarComparisonNotifier() : super([]);

  void addCar(CarModel car) {
    if (!state.contains(car) && state.length < 3) {
      state = [...state, car];
    }
  }

  void removeCar(CarModel car) {
    state = state.where((c) => c.id != car.id).toList();
  }

  void clearCars() {
    state = [];
  }

  bool canAddCar() {
    return state.length < 3;
  }

  bool containsCar(CarModel car) {
    return state.any((c) => c.id == car.id);
  }
}

final carComparisonProvider =
    StateNotifierProvider<CarComparisonNotifier, List<CarModel>>((ref) {
      return CarComparisonNotifier();
    });

class CarComparisonScreen extends ConsumerWidget {
  const CarComparisonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparedCars = ref.watch(carComparisonProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Comparison'),
        actions: [
          if (comparedCars.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                ref.read(carComparisonProvider.notifier).clearCars();
              },
            ),
        ],
      ),
      body: comparedCars.isEmpty
          ? _buildEmptyState(context, ref)
          : _buildComparisonTable(context, comparedCars, ref),
      floatingActionButton: comparedCars.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showAddCarDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Add Car'),
            )
          : null,
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.compare_arrows, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No cars to compare',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add cars from your garage or search to compare them',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddCarDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Add Cars to Compare'),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable(
    BuildContext context,
    List<CarModel> cars,
    WidgetRef ref,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          const DataColumn(label: Text('Specification')),
          ...cars.map(
            (car) => DataColumn(
              label: SizedBox(
                width: 120,
                child: Column(
                  children: [
                    Container(
                      height: 80,
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[300],
                      ),
                      child: car.imageUrls.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: car.imageUrls.first,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Center(
                                      child: Icon(Icons.directions_car),
                                    ),
                              ),
                            )
                          : const Center(child: Icon(Icons.directions_car)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      car.displayName,
                      style: Theme.of(context).textTheme.titleSmall,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () {
                        ref.read(carComparisonProvider.notifier).removeCar(car);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        rows: _buildComparisonRows(cars),
      ),
    );
  }

  List<DataRow> _buildComparisonRows(List<CarModel> cars) {
    return [
      DataRow(
        cells: [
          const DataCell(Text('Make')),
          ...cars.map((car) => DataCell(Text(car.make))),
        ],
      ),
      DataRow(
        cells: [
          const DataCell(Text('Model')),
          ...cars.map((car) => DataCell(Text(car.model))),
        ],
      ),
      DataRow(
        cells: [
          const DataCell(Text('Year')),
          ...cars.map((car) => DataCell(Text(car.year.toString()))),
        ],
      ),
      DataRow(
        cells: [
          const DataCell(Text('Color')),
          ...cars.map((car) => DataCell(Text(car.color ?? 'N/A'))),
        ],
      ),
      DataRow(
        cells: [
          const DataCell(Text('Description')),
          ...cars.map((car) => DataCell(Text(car.description ?? 'N/A'))),
        ],
      ),
      DataRow(
        cells: [
          const DataCell(Text('Modifications')),
          ...cars.map((car) => DataCell(Text(car.modifications.join(', ')))),
        ],
      ),
    ];
  }

  void _showAddCarDialog(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final comparisonNotifier = ref.read(carComparisonProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Car to Comparison'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: currentUser.when(
            data: (user) {
              if (user == null) {
                return const Center(child: Text('Please log in'));
              }

              final availableCars = user.cars
                  .where((car) => !comparisonNotifier.containsCar(car))
                  .toList();

              if (availableCars.isEmpty) {
                return const Center(
                  child: Text('No more cars available to compare'),
                );
              }

              return ListView.builder(
                itemCount: availableCars.length,
                itemBuilder: (context, index) {
                  final car = availableCars[index];
                  return Card(
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[300],
                        ),
                        child: car.imageUrls.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: car.imageUrls.first,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Center(
                                        child: Icon(Icons.directions_car),
                                      ),
                                ),
                              )
                            : const Center(child: Icon(Icons.directions_car)),
                      ),
                      title: Text(car.displayName),
                      subtitle: Text('${car.year} • ${car.color ?? 'N/A'}'),
                      trailing: comparisonNotifier.canAddCar()
                          ? const Icon(Icons.add)
                          : const Icon(Icons.block),
                      onTap: () {
                        if (comparisonNotifier.canAddCar()) {
                          comparisonNotifier.addCar(car);
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class CarComparisonButton extends ConsumerWidget {
  final CarModel car;
  final bool isSelected;

  const CarComparisonButton({
    super.key,
    required this.car,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparisonNotifier = ref.read(carComparisonProvider.notifier);

    return IconButton(
      icon: Icon(
        isSelected ? Icons.compare_arrows : Icons.compare_outlined,
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      ),
      onPressed: () {
        if (isSelected) {
          comparisonNotifier.removeCar(car);
        } else if (comparisonNotifier.canAddCar()) {
          comparisonNotifier.addCar(car);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maximum 3 cars can be compared at once'),
            ),
          );
        }
      },
      tooltip: isSelected ? 'Remove from comparison' : 'Add to comparison',
    );
  }
}
