import paramiko

def inspect_db():
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect('76.13.245.174', username='root', password='Am5royal@2026')
    
    stdin, stdout, stderr = client.exec_command('docker exec -i -w /app -e PYTHONPATH=/app am5_backend python /app/scratch/temp_inspect.py')
    print(stdout.read().decode())
    err = stderr.read().decode()
    if err:
        print("Error:", err)
    client.close()

if __name__ == '__main__':
    inspect_db()
