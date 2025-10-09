#!/usr/bin/env python3
"""
CSV to Firestore Uploader for TNPS Hostel League Teams
This script reads CSV files and uploads team member data to Firestore
"""

import csv
import firebase_admin
from firebase_admin import credentials, firestore
import os

def initialize_firebase():
    """Initialize Firebase Admin SDK"""
    try:
        # Initialize Firebase Admin SDK
        # You'll need to download your service account key JSON file
        cred = credentials.Certificate('path/to/your/serviceAccountKey.json')
        firebase_admin.initialize_app(cred)
        print("Firebase initialized successfully!")
        return True
    except Exception as e:
        print(f"Error initializing Firebase: {e}")
        return False

def upload_team_data(csv_file_path, collection_name):
    """Upload team data from CSV to Firestore"""
    try:
        db = firestore.client()
        
        # Clear existing data
        docs = db.collection(collection_name).stream()
        for doc in docs:
            doc.reference.delete()
        print(f"Cleared existing data for {collection_name}")
        
        # Read CSV and upload data
        members_added = 0
        with open(csv_file_path, 'r', encoding='utf-8') as file:
            csv_reader = csv.reader(file)
            next(csv_reader)  # Skip header row
            
            for row in csv_reader:
                if len(row) >= 2 and row[1].strip():  # Check if name exists
                    name = row[1].strip()
                    member_data = {
                        'name': name,
                        'phone_number': '0000000000',  # Placeholder
                        'room_number': 'TBD',  # To be determined
                        'year': 'TBD',  # To be determined
                        'cultural_activity': 'TBD',  # To be determined
                        'sports': [],  # Empty - can be filled later
                        'player_status': 'false',
                        'team_name': collection_name,
                    }
                    
                    db.collection(collection_name).add(member_data)
                    members_added += 1
        
        print(f"Successfully uploaded {members_added} members to {collection_name}")
        return True
        
    except Exception as e:
        print(f"Error uploading data for {collection_name}: {e}")
        return False

def main():
    """Main function to upload all team data"""
    if not initialize_firebase():
        return
    
    # Define team CSV files and collection names
    teams = [
        ('assets/scout regiment.csv', 'The Scout Regiment'),
        ('assets/white walker.csv', 'White Walkers'),
        ('assets/rising giants.csv', 'Rising Giants'),
        ('assets/anna.csv', 'Anna Warriors'),
    ]
    
    print("Starting CSV to Firestore upload process...")
    
    for csv_file, collection_name in teams:
        if os.path.exists(csv_file):
            print(f"\nProcessing {csv_file}...")
            upload_team_data(csv_file, collection_name)
        else:
            print(f"CSV file not found: {csv_file}")
    
    print("\nUpload process completed!")

if __name__ == "__main__":
    main()
