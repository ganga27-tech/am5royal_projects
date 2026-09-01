
import os
import paramiko
import time

VPS_HOST = "76.13.245.174"
VPS_USER = "root"
VPS_PASS = "Am5royal@2026"
REMOTE_DIR = "/root/am5-backend"

def deploy():
    print(f"Connecting to {VPS_HOST} via SSH/SFTP...")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(VPS_HOST, username=VPS_USER, password=VPS_PASS, timeout=30)
    sftp = ssh.open_sftp()
    
    files_to_sync = [
        "app/main.py",
        "app/api/v1/api.py",
        "app/models/__init__.py",
        "app/models/developer_portal.py",
        "app/schemas/developer_portal.py",
        "app/services/bug_workflow_service.py",
        "app/services/developer_service.py",
        "app/dependencies/developer_auth.py",
        "app/api/v1/endpoints/developer.py",
        "app/db/migrate_developer_portal.py",
        "app/db/migrate_project_head.py",
        "app/api/v1/endpoints/auth.py",
        "app/api/v1/endpoints/location.py",
        "app/api/v1/endpoints/orders.py",
        "app/api/v1/endpoints/catalog.py",
    ]
    
    for rel_path in files_to_sync:
        local_path = os.path.join(os.path.dirname(__file__), "..", rel_path)
        local_path = os.path.normpath(local_path)
        remote_path = f"{REMOTE_DIR}/{rel_path}".replace("\\", "/")
        print(f"Uploading {local_path} -> {remote_path}...")
        sftp.put(local_path, remote_path)
        
        # Also copy directly into the running container if am5_backend is running
        container_path = f"/app/{rel_path}".replace("\\", "/")
        docker_cp_cmd = f"docker cp {remote_path} am5_backend:{container_path}"
        stdin, stdout, stderr = ssh.exec_command(docker_cp_cmd)
        out = stdout.read().decode()
        err = stderr.read().decode()
        if err and "Error" in err:
            print(f"Warning docker cp: {err}")
    
    sftp.close()

    print("Running developer portal migration inside container...")
    stdin, stdout, stderr = ssh.exec_command("docker exec -i am5_backend python -m app.db.migrate_developer_portal")
    print(stdout.read().decode())
    stdin, stdout, stderr = ssh.exec_command("docker exec -i am5_backend python -m app.db.migrate_project_head")
    print(stdout.read().decode())
    err = stderr.read().decode()
    if err:
        print("Migration error:", err)
    
    print("Rebuilding/restarting docker container...")
    # Restart am5_backend or docker compose down/up
    restart_cmd = "cd /root/am5-backend && docker compose restart backend"
    stdin, stdout, stderr = ssh.exec_command(restart_cmd)
    print("Output:", stdout.read().decode())
    print("Error:", stderr.read().decode())
    
    time.sleep(3)
    
    print("Checking container logs...")
    stdin, stdout, stderr = ssh.exec_command("docker logs am5_backend --tail 30")
    print("=== Last 30 lines of am5_backend logs ===")
    print(stdout.read().decode())
    print(stderr.read().decode())
    
    print("Testing /health check...")
    stdin, stdout, stderr = ssh.exec_command("curl -s http://localhost:8000/health")
    health_resp = stdout.read().decode()
    print("Health check response:", health_resp)
    
    ssh.close()
    print("Deployment completed successfully!")

if __name__ == "__main__":
    deploy()
