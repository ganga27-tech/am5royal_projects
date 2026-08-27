import paramiko

def check_vps():
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        client.connect("76.13.245.174", username="root", password="Am5royal@2026", timeout=15)
        print("Connected to VPS successfully!")
        
        stdin, stdout, stderr = client.exec_command("docker ps")
        print("Docker PS:")
        print(stdout.read().decode())
        
        stdin, stdout, stderr = client.exec_command("ls -la /root/am5-backend")
        print("am5-backend dir:")
        print(stdout.read().decode())
        
    except Exception as e:
        print(f"Error connecting: {e}")
    finally:
        client.close()

if __name__ == "__main__":
    check_vps()
