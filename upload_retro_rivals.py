import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import csv

# --- IMPORTANT: Update the path to your serviceAccountKey.json ---
# Make sure this file is in your project's root directory
cred = credentials.Certificate('./serviceAccountKey.json')
firebase_admin.initialize_app(cred)

db = firestore.client()

# --- IMPORTANT: Update the path to your retro_rivals_tempelate.csv ---
# Make sure this file is in your assets directory as provided in the prompt.
csv_file_path = 'assets/Retro_main.csv'
collection_name = 'Retro Rivals'

def upload_players_from_csv(file_path, collection):
    with open(file_path, mode='r', encoding='utf-8-sig') as file: # Use utf-8-sig to handle BOM
        reader = csv.reader(file)
        headers = [h.strip() for h in next(reader)] # Read and clean headers manually

        for row_values in reader:
            if not row_values or all(not val.strip() for val in row_values): # Skip empty rows
                continue

            # Manually create a dictionary for the row using cleaned headers
            cleaned_row = dict(zip(headers, row_values))

            player_data = {
                'name': cleaned_row.get('Name', ''),
                # 'year': cleaned_row.get('Year', ''),
                # 'phone_number': cleaned_row.get('Phone', ''),
                # 'room_number': cleaned_row.get('Room', ''),
                # 'cultural_activity': cleaned_row.get('Cultural', ''),
                # 'relay': cleaned_row.get('Relay', ''),
                # 'rainbow': cleaned_row.get('Rainbow', ''),
                # 'sports': [s.strip() for s in cleaned_row.get('Sport', '').split(',') if s.strip()],
                # 'team_name': collection_name,
                # 'player_status': False, # Default to False as per image example
            }
            # Add a new document with an auto-generated ID
            db.collection(collection).add(player_data)
            print(f"Uploaded {cleaned_row.get('Name', 'Unnamed')} to {collection_name}")

if __name__ == '__main__':
    print(f"Starting upload for {collection_name} from {csv_file_path}...")
    upload_players_from_csv(csv_file_path, collection_name)
    print("Upload complete.")
