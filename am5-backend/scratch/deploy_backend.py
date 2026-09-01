import os
import sys
import paramiko

if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

HOST = "76.13.245.174"
USER = "root"
PASS = "Am5royal@2026"
REMOTE_DIR = "/root/am5-backend"
LOCAL_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

EXCLUDE_DIRS = {".git", "venv", "scratch", "__pycache__", ".pytest_cache", ".idea", ".vscode"}
EXCLUDE_FILES = {".DS_Store"}

def should_exclude(rel_path):
    parts = rel_path.replace("\\", "/").split("/")
    for p in parts:
        if p in EXCLUDE_DIRS:
            return True
    filename = os.path.basename(rel_path)
    if filename in EXCLUDE_FILES or filename.endswith(".pyc"):
        return True
    return False

def deploy():
    print(f"Connecting to {HOST}...")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    print("SSH Connection established.")

    sftp = ssh.open_sftp()

    # Ensure remote base dir exists
    try:
        sftp.stat(REMOTE_DIR)
    except IOError:
        sftp.mkdir(REMOTE_DIR)

    remote_dirs_created = set()

    def ensure_remote_dir(remote_path):
        if remote_path in remote_dirs_created:
            return
        dirs = remote_path.split("/")
        current = ""
        for d in dirs:
            if not d:
                current = "/"
                continue
            current = os.path.join(current, d).replace("\\", "/")
            try:
                sftp.stat(current)
            except IOError:
                print(f"Creating remote dir: {current}")
                sftp.mkdir(current)
        remote_dirs_created.add(remote_path)

    print("Uploading local project files...")
    upload_count = 0

    for root, dirs, files in os.walk(LOCAL_DIR):
        rel_root = os.path.relpath(root, LOCAL_DIR)
        if rel_root == ".":
            rel_root = ""
        
        # Exclude directories in place
        dirs[:] = [d for d in dirs if not should_exclude(os.path.join(rel_root, d))]

        for file in files:
            rel_file = os.path.join(rel_root, file)
            if should_exclude(rel_file):
                continue
            
            local_path = os.path.join(root, file)
            remote_path = os.path.join(REMOTE_DIR, rel_file).replace("\\", "/")
            remote_parent = os.path.dirname(remote_path)
            
            ensure_remote_dir(remote_parent)
            
            sftp.put(local_path, remote_path)
            upload_count += 1

    print(f"Uploaded {upload_count} files to {REMOTE_DIR}.")
    sftp.close()

    # Run docker compose down && docker compose up -d --build
    cmd = f"cd {REMOTE_DIR} && docker compose down && docker compose up -d --build"
    print(f"Executing remote command: {cmd}")
    stdin, stdout, stderr = ssh.exec_command(cmd, get_pty=True)

    for line in iter(stdout.readline, ""):
        print(line, end="")

    exit_status = stdout.channel.recv_exit_status()
    print(f"\nCommand completed with exit code: {exit_status}")

    if exit_status == 0:
        migrate_cmd = (
            f"cd {REMOTE_DIR} && docker compose exec -T backend "
            f"python -m app.db.migrate_careers_tables"
        )
        print(f"Ensuring career tables: {migrate_cmd}")
        stdin, stdout, stderr = ssh.exec_command(migrate_cmd, get_pty=True)
        for line in iter(stdout.readline, ""):
            print(line, end="")
        migrate_exit = stdout.channel.recv_exit_status()
        print(f"Migration exit code: {migrate_exit}")

        call_log_cmd = (
            f"cd {REMOTE_DIR} && docker compose exec -T backend "
            f"python create_call_log_table.py"
        )
        print(f"Ensuring call log tables: {call_log_cmd}")
        stdin, stdout, stderr = ssh.exec_command(call_log_cmd, get_pty=True)
        for line in iter(stdout.readline, ""):
            print(line, end="")
        call_log_exit = stdout.channel.recv_exit_status()
        print(f"Call log table creation exit code: {call_log_exit}")

    # Verify containers running
    print("\nChecking docker container status...")
    stdin, stdout, stderr = ssh.exec_command("docker ps --filter name=am5", get_pty=True)
    print(stdout.read().decode())

    ssh.close()

if __name__ == "__main__":
    deploy()
