// ignore_for_file: unnecessary_null_comparison
import 'package:flutter/material.dart';
import 'package:gymvisa/models/GymModel.dart';
import 'package:gymvisa/services/database_service.dart';

class GymListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List of Gyms'),
      ),
      body: FutureBuilder<List<Gym>>(
        future: Database_Service.getAllGyms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              List<Gym> gyms = snapshot.data ?? [];
              return ListView.builder(
                itemCount: gyms.length,
                itemBuilder: (context, index) {
                  Gym gym = gyms[index];
                  return ListTile(
                    title: Text(gym.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${gym.gymID}', style: TextStyle(fontWeight: FontWeight.w900)),
                        Text('${gym.city}, ${gym.country}'),
                        Text('Subscription: ${gym.subscription}'),
                        Text('Phone: ${gym.phoneNo}'),
                        Text('Email: ${gym.email}'),
                        Text('Description: ${gym.description}'),
                        Text('Address: ${gym.address}'),
                        Text('Google Maps: ${gym.googleMapsLink}'),
                        // Display the images from Firebase Storage
                        if (gym.imageUrl1 != null && gym.imageUrl1.isNotEmpty)
                          Image.network(gym.imageUrl1),
                        if (gym.imageUrl2 != null && gym.imageUrl2.isNotEmpty)
                          Image.network(gym.imageUrl2),
                        SizedBox(height: 10), // Optional spacing
                        Center(
                          child: gym.qrCodeUrl != null
                              ? Image.network(
                                  gym.qrCodeUrl!,
                                  width: 200.0,
                                  height: 200.0,
                                )
                              : Text('No QR code available'),
                        ),
                      ],
                    ),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(gym.imageUrl1), // Use imageUrl1 as leading avatar
                    ),
                    onTap: () {
                      // Handle onTap if needed
                    },
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}

