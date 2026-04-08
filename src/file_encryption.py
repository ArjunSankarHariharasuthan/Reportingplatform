from cryptography.fernet import Fernet

# Step 1: Generate a key (run this once, then save/share the key securely)
key = Fernet.generate_key()
with open("secret.key", "wb") as key_file:
    key_file.write(key)

# Step 2: Load the key
with open("secret.key", "rb") as key_file:
    key = key_file.read()

# Step 3: Encrypt the file
fernet = Fernet(key)

with open("account_20250801010830.csv", "rb") as file:
    original = file.read()

encrypted = fernet.encrypt(original)

with open("account_20250801010830_encrypted.csv.enc", "wb") as encrypted_file:
    encrypted_file.write(encrypted)

print("File encrypted successfully!")
