import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/event_model.dart';
import '../../../data/models/event_submission_model.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/app_providers.dart';
import '../../../core/utils/constants.dart';
import 'package:uuid/uuid.dart';

class SubmitCarScreen extends ConsumerStatefulWidget {
  final EventModel event;

  const SubmitCarScreen({
    super.key,
    required this.event,
  });

  @override
  ConsumerState<SubmitCarScreen> createState() => _SubmitCarScreenState();
}

class _SubmitCarScreenState extends ConsumerState<SubmitCarScreen> {
  CarModel? _selectedCar;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Your Car'),
      ),
      body: currentUser.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('Please log in to submit a car'),
            );
          }

          if (user.cars.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.directions_car_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No cars in your garage',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a car to your garage first',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to add car screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Add car feature coming soon!')),
                      );
                    },
                    child: const Text('Add Car to Garage'),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select a car from your garage:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                
                const SizedBox(height: 16),
                
                // Car selection
                ...user.cars.map((car) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: RadioListTile<CarModel>(
                    title: Text(car.displayName),
                    subtitle: Text('${car.make} ${car.model}'),
                    value: car,
                    groupValue: _selectedCar,
                    onChanged: (CarModel? value) {
                      setState(() => _selectedCar = value);
                    },
                    secondary: car.imageUrls.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              car.imageUrls.first,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.directions_car),
                                );
                              },
                            ),
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.directions_car),
                          ),
                  ),
                )),
                
                const SizedBox(height: 24),
                
                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedCar != null && !_isSubmitting
                        ? _submitCar
                        : null,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit Car'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Future<void> _submitCar() async {
    if (_selectedCar == null) return;

    setState(() => _isSubmitting = true);

    try {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) return;

      final firestoreService = ref.read(firestoreServiceProvider);

      // Create submission
      final submission = EventSubmissionModel(
        id: const Uuid().v4(),
        eventId: widget.event.id,
        userId: currentUser.id,
        carId: _selectedCar!.id,
        submittedAt: DateTime.now(),
      );

      await firestoreService.submitCarToEvent(submission);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Car submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit car: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
