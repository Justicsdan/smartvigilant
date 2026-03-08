from cryptography.fernet import Fernet

key = Fernet.generate_key()
cipher = Fernet(key)

def encrypt(data):
    return cipher.encrypt(data.encode())

def decrypt(encrypted):
    return cipher.decrypt(encrypted).decode()
