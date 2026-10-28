import os
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build

# If modifying these scopes, delete the file token.json.
SCOPES = ['https://www.googleapis.com/auth/books']

def get_authenticated_service():
    creds = None
    if os.path.exists('token.json'):
        creds = Credentials.from_authorized_user_file('token.json', SCOPES)
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                'credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        with open('token.json', 'token') as token:
            token.write(creds.to_json())
    return build('books', 'v1', credentials=creds)

def search_and_manage_library(query_string, action='list'):
    service = get_authenticated_service()
    
    # Access user's bookshelf (Volume shelf or MyLibrary)
    # Note: Google Books API allows searching user volumes (mylibrary/bookshelves)
    print(f"Searching library for query: '{query_string}'...")
    
    # Retrieve user's bookshelves first
    shelves = service.bookshelves().list(userId='me').execute()
    
    if 'items' not in shelves:
        print("No bookshelves found.")
        return

    for shelf in shelves['items']:
        shelf_id = shelf['id']
        shelf_title = shelf['title']
        print(f"\nChecking shelf: {shelf_title} (ID: {shelf_id})")
        
        # List volumes in the shelf
        volumes = service.bookshelves().volumes().list(
            userId='me', shelf=shelf_id
        ).execute()
        
        if 'items' not in volumes:
            continue
            
        for volume in volumes['items']:
            vol_id = volume['id']
            volume_info = volume.get('volumeInfo', {})
            title = volume_info.get('title', 'Unknown Title')
            authors = ", ".join(volume_info.get('authors', ['Unknown Author']))
            
            # Check if query matches title or author
            if query_string.lower() in title.lower() or query_string.lower() in authors.lower():
                print(f"  [MATCH] Found: '{title}' by {authors} (ID: {vol_id})")
                
                if action == 'delete':
                    try:
                        service.mylibrary().bookshelves().removeVolume(
                            userId='me', shelf=shelf_id, volumeId=vol_id
                        ).execute()
                        print(f"    -> Successfully removed '{title}' from shelf.")
                    except Exception as e:
                        print(f"    -> Error removing volume: {e}")

if __name__ == '__main__':
    import sys
    # Example usage via command line:
    # python delete_books.py "Search Term" delete
    query = sys.argv[1] if len(sys.argv) > 1 else input("Enter search term for books: ")
    mode = sys.argv[2] if len(sys.argv) > 2 else input("Action ('list' or 'delete'): ")
    
    search_and_manage_library(query, action=mode)